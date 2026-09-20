# Script para compilar la APK de Flutter localmente en Windows
param(
    [string]$Mode = "debug" # "debug" o "release"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     COMPILADOR AUTOMÁTICO DE APK - ROBOT CONTROL         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterCmd) {
    Write-Host "[!] Flutter SDK no fue encontrado en el PATH de este sistema." -ForegroundColor Yellow
    Write-Host "Para compilar localmente necesitas:" -ForegroundColor White
    Write-Host " 1. Descargar Flutter SDK de https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Gray
    Write-Host " 2. Extraer en C:\flutter y agregar C:\flutter\bin a tus Variables de Entorno (PATH)." -ForegroundColor Gray
    Write-Host " 3. Tener Android Studio instalado con 'Android SDK Command-line Tools'." -ForegroundColor Gray
    Write-Host ""
    Write-Host "[TIP] ALTERNATIVA SIN INSTALAR NADA EN TU PC:" -ForegroundColor Green
    Write-Host " Puedes subir esta carpeta a un repositorio privado de GitHub y la APK" -ForegroundColor Green
    Write-Host " se compilará automáticamente en la nube gracias al archivo:" -ForegroundColor Green
    Write-Host "   .github/workflows/build_apk.yml" -ForegroundColor Green
    Write-Host " Podrás descargar el archivo .apk directamente a tu teléfono desde la pestaña 'Actions'." -ForegroundColor Green
    exit 1
}

$appDir = Join-Path $PSScriptRoot "..\mobile_app"
Set-Location $appDir

Write-Host "[1/3] Descargando paquetes y dependencias (flutter pub get)..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error obteniendo dependencias." -ForegroundColor Red
    exit 1
}

Write-Host "[2/3] Compilando APK ($Mode)..." -ForegroundColor Cyan
if ($Mode -eq "release") {
    flutter build apk --release --no-tree-shake-icons
} else {
    flutter build apk --debug
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error en la compilación de la APK." -ForegroundColor Red
    exit 1
}

Write-Host "[3/3] ¡Compilación exitosa!" -ForegroundColor Green
$apkPath = Join-Path $appDir "build\app\outputs\flutter-apk\app-$Mode.apk"
Write-Host "Archivo APK generado en: $apkPath" -ForegroundColor Yellow
