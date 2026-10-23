"""Internal stateless matcher. PostgreSQL in the HRIS API owns reference photos."""
import base64
import binascii
import hmac
import os
import threading

import cv2
import numpy as np
from deepface import DeepFace
from flask import Flask, jsonify, request

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 9 * 1024 * 1024
lock = threading.Lock()
KEY = os.environ.get('FACE_PROVIDER_KEY', '')
# Load weights before health can pass; never advertise readiness during model startup.
DeepFace.build_model('SFace')
DeepFace.build_model('opencv', task='face_detector')
DeepFace.build_model('Fasnet', task='spoofing')


def image(value):
    if not isinstance(value, str) or len(value) > 4 * 1024 * 1024 + 64:
        raise ValueError('invalid photo')
    prefix, payload = value.split(',', 1)
    if prefix not in ('data:image/jpeg;base64', 'data:image/png;base64'):
        raise ValueError('unsupported photo')
    raw = base64.b64decode(payload, validate=True)
    if len(raw) > 3 * 1024 * 1024:
        raise ValueError('photo too large')
    decoded = cv2.imdecode(np.frombuffer(raw, dtype=np.uint8), cv2.IMREAD_COLOR)
    if decoded is None or not all(160 <= n <= 4096 for n in decoded.shape[:2]):
        raise ValueError('invalid dimensions')
    return decoded


def embedding(value):
    faces = DeepFace.represent(img_path=image(value), model_name='SFace',
        detector_backend='opencv', enforce_detection=True, align=True,
        anti_spoofing=True)
    if len(faces) != 1:
        raise ValueError('exactly one live face required')
    return faces[0]['embedding']


@app.before_request
def authenticate():
    if request.path == '/health':
        return None
    expected = 'Bearer ' + KEY
    if not KEY or not hmac.compare_digest(request.headers.get('Authorization', ''), expected):
        return jsonify(success=False), 401
    return None


@app.get('/health')
def health():
    return jsonify(ok=bool(KEY)), 200 if KEY else 503


@app.post('/enroll')
def enroll():
    try:
        with lock:
            embedding(request.get_json()['image'])
        return jsonify(success=True, live=True)
    except (ValueError, KeyError, TypeError, binascii.Error):
        return jsonify(success=False, live=False), 422


@app.post('/verify')
def verify():
    try:
        body = request.get_json()
        with lock:
            candidate = embedding(body['image'])
            reference = embedding(body['referenceImage'])
            result = DeepFace.verify(img1_path=candidate, img2_path=reference,
                model_name='SFace', distance_metric='cosine', silent=True)
        return jsonify(success=True, matched=bool(result['verified']), live=True)
    except (ValueError, KeyError, TypeError, binascii.Error):
        return jsonify(success=False, matched=False, live=False), 422


@app.errorhandler(500)
def unavailable(_error):
    # No input images or model exception details in API responses.
    return jsonify(success=False, matched=False, live=False), 503
