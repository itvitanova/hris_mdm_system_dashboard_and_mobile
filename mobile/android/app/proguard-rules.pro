# ML Kit discovers components through Android manifest metadata and a runtime
# component graph. Keep the SDK graph intact in optimized release builds.
# The production crash resolves to zzmj's null SharedPrefManager constructor
# argument while InputImage.fromByteArray initializes the vision-common logger.
# Scope this protection to ML Kit and its component registry, not the whole app.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_face.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_face_bundled.** { *; }
-keep class com.google.firebase.components.** { *; }
-keep class com.google.firebase.inject.** { *; }
-keepattributes Signature,*Annotation*
