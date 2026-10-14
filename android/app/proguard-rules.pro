# flutter_local_notifications guarda os lembretes agendados com Gson. Sem estas
# regras, o R8 do build release apaga as assinaturas genéricas e o agendamento
# falha com "Missing type parameter" (no debug funciona).
# Regras do Gson: https://github.com/google/gson/blob/main/examples/android-proguard-example/proguard.cfg
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Os lembretes salvos são lidos de novo após reiniciar o aparelho ou atualizar o
# app: os nomes dos campos não podem mudar entre builds.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
