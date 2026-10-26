"""Exercise the real provider without enrolling an employee or saving a photo."""
import base64
import json
import os
import urllib.error
import urllib.request
import cv2
import numpy as np

base = 'http://127.0.0.1:8000'
with urllib.request.urlopen(base + '/health', timeout=15) as response:
    assert response.status == 200 and json.load(response)['ok'] is True

encoded = cv2.imencode('.jpg', np.zeros((320, 320, 3), dtype=np.uint8))[1]
blank = 'data:image/jpeg;base64,' + base64.b64encode(encoded).decode()
def check(path, body, key, expected):
    req = urllib.request.Request(base + path, data=json.dumps(body).encode(), headers={
        'Content-Type': 'application/json', 'Authorization': 'Bearer ' + key,
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            status, payload = response.status, json.load(response)
    except urllib.error.HTTPError as error:
        status, payload = error.code, json.load(error)
    assert status == expected and payload.get('success') is False, (path, status)
    assert payload.get('matched', False) is False
    assert payload.get('live', False) is False

check('/enroll', {'image': blank}, 'invalid-provider-key', 401)
check('/enroll', {'image': blank}, os.environ['FACE_PROVIDER_KEY'], 422)
check('/verify', {'image': blank, 'referenceImage': blank}, os.environ['FACE_PROVIDER_KEY'], 422)
print('Provider healthy; unauthorized requests and blank-image enrollment/verification rejected.')
