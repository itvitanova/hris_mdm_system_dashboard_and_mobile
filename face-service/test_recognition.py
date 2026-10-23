"""Opt-in model smoke test using upstream DeepFace fixtures, never employee data."""
import os
import unittest
import urllib.request
import cv2
import numpy as np
from deepface import DeepFace


@unittest.skipUnless(os.environ.get('FACE_TEST_FIXTURES') == '1', 'requires upstream fixture download')
class RecognitionTests(unittest.TestCase):
    def test_same_person_matches_and_different_person_fails(self):
        images = []
        for name in ('img1.jpg', 'img2.jpg', 'img3.jpg'):
            url = 'https://raw.githubusercontent.com/serengil/deepface/v0.0.99/tests/unit/dataset/' + name
            with urllib.request.urlopen(url, timeout=30) as response:
                data = response.read()
            images.append(cv2.imdecode(np.frombuffer(data, dtype=np.uint8), cv2.IMREAD_COLOR))
        # Recognition only: these downloaded fixtures do not test live phone capture.
        same = DeepFace.verify(img1_path=images[0], img2_path=images[1], model_name='SFace', silent=True)
        different = DeepFace.verify(img1_path=images[0], img2_path=images[2], model_name='SFace', silent=True)
        self.assertTrue(same['verified'], same)
        self.assertFalse(different['verified'], different)


if __name__ == '__main__':
    unittest.main()
