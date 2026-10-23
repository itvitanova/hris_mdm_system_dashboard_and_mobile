from deepface import DeepFace

# Download at build time: first employee request must not download model weights.
DeepFace.build_model('SFace')
DeepFace.build_model('opencv', task='face_detector')
DeepFace.build_model('Fasnet', task='spoofing')
