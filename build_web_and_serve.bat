@echo off
REM Build the Flutter web app and serve it on port 8091.
REM Usage:  build_web_and_serve.bat
setlocal
pushd %~dp0
echo === flutter build web --release ===
call flutter build web --release || goto :err
echo.
echo === serving build/web at http://127.0.0.1:8091 ===
dart run tool/serve_web.dart 8091
popd
exit /b 0
:err
popd
echo Build failed.
exit /b 1
