# Keep TensorFlow Lite GPU classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keepclassmembers class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }