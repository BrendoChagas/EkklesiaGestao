@echo off
echo "============================================="
echo "   GERADOR DE APK - Ekklesia Gestao         "
echo "============================================="
echo.

set "JAVA_HOME=C:\Users\BrendoC\AppData\Local\Java\jdk-17.0.18+8"
echo [OK] Java 17 do Windows configurado explicitamente!

echo.
echo "Limpando e verificando dependencias..."
call D:\_Projetos\ff_flutter_sdk\flutter\bin\flutter.bat clean
call D:\_Projetos\ff_flutter_sdk\flutter\bin\flutter.bat pub get

echo.
echo "Construindo APK (Isso pode levar alguns minutos)..."
call D:\_Projetos\ff_flutter_sdk\flutter\bin\flutter.bat build apk --debug

echo.
echo "Processo finalizado!"
pause
