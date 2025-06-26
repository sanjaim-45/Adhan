# Keep ExoPlayer and just_audio
-keep class com.google.android.exoplayer2.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-keep class androidx.media3.** { *; }
-keep class com.google.common.** { *; }
-dontwarn com.google.android.exoplayer2.**
-dontwarn com.ryanheise.just_audio.**
