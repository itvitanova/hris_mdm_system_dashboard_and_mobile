import base64
import unittest
from unittest.mock import patch
import cv2
import numpy as np
import app as service


class FaceServiceTests(unittest.TestCase):
    def setUp(self):
        service.KEY = 'test-secret'
        self.client = service.app.test_client()
        self.headers = {'Authorization': 'Bearer test-secret'}
        _, data = cv2.imencode('.jpg', np.zeros((200, 200, 3), dtype=np.uint8))
        self.photo = 'data:image/jpeg;base64,' + base64.b64encode(data).decode()

    def test_authentication_and_local_data_only(self):
        self.assertEqual(self.client.post('/enroll', json={'image': self.photo}).status_code, 401)
        result = self.client.post('/enroll', json={'image': 'https://example.com/photo'}, headers=self.headers)
        self.assertEqual(result.status_code, 422)

    def test_rejects_no_face_multiple_faces_and_spoof(self):
        for result in ([], [{'embedding': [1.]}, {'embedding': [2.]}]):
            with patch.object(service.DeepFace, 'represent', return_value=result):
                self.assertEqual(self.client.post('/enroll', json={'image': self.photo}, headers=self.headers).status_code, 422)
        with patch.object(service.DeepFace, 'represent', side_effect=ValueError('spoof')):
            self.assertEqual(self.client.post('/verify', json={'image': self.photo, 'referenceImage': self.photo}, headers=self.headers).status_code, 422)

    def test_identity_result_is_never_overridden_by_liveness(self):
        for matched in (False, True):
            with patch.object(service.DeepFace, 'represent', return_value=[{'embedding': [1.0]}]) as represent, patch.object(service.DeepFace, 'verify', return_value={'verified': matched}):
                result = self.client.post('/verify', json={'image': self.photo, 'referenceImage': self.photo}, headers=self.headers)
                self.assertEqual(result.json, {'success': True, 'matched': matched, 'live': True})
                self.assertEqual(represent.call_count, 2)
                self.assertTrue(all(call.kwargs['anti_spoofing'] and call.kwargs['enforce_detection'] for call in represent.call_args_list))

    def test_real_detector_rejects_blank_photo(self):
        result = self.client.post('/enroll', json={'image': self.photo}, headers=self.headers)
        self.assertEqual(result.status_code, 422)


if __name__ == '__main__':
    unittest.main()
