# Internal face matcher

The Go API owns account authorization, enrollment state, reference photos, and geofencing. This service receives a candidate and a server-selected reference, computes SFace embeddings with DeepFace, and applies its cosine verification threshold. Both images must contain exactly one face and pass FasNet passive anti-spoofing. Enrollment validates the first image; it does not create an account.

The model weights download during `docker compose build face`. The first build installs CPU PyTorch and TensorFlow and can take time. The service has no published host port. Requests require the shared `FACE_PROVIDER_KEY`; photos and embeddings are not persisted here.

Run tests from the repository root with Docker and `.env` configured:

```powershell
docker compose run --rm --no-deps --volume "${PWD}/face-service:/tests:ro" face python -m unittest discover -s /tests -v
```

To also test actual same/different identity recognition using the upstream DeepFace fixture images (requires internet):

```powershell
docker compose run --rm --no-deps --env FACE_TEST_FIXTURES=1 --volume "${PWD}/face-service:/tests:ro" face python -m unittest discover -s /tests -v
```

`test_app.py` covers authentication, invalid images, blank-image detection with the actual detector, multiple faces, spoof rejection, and preservation of the match result. Some model responses are mocked to deterministically exercise rejection paths. `test_recognition.py` tests actual SFace recognition on downloaded fixtures; it does not test live phone capture. Real phone enrollment/attendance, lighting, camera quality, and spoof acceptance/rejection must be checked on target hardware. Passive anti-spoofing is not a one-time challenge and does not prevent request replay.

Library and model API reference: [DeepFace v0.0.99](https://github.com/serengil/deepface/tree/v0.0.99).
