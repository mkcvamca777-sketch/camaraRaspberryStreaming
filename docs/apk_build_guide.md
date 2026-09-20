# Guía Paso a Paso para Generar la APK (Android)

Esta guía explica las dos formas disponibles para obtener el archivo instalable `.apk` para tu smartphone Android:
1. **Método A (Automático en la Nube con GitHub Actions):** No requiere instalar 10 GB de Flutter, Gradle ni Android Studio en tu PC.
2. **Método B (Compilación Local en tu PC):** Si tienes o deseas instalar Flutter SDK en Windows.

---

## Método A: Compilación Automática en la Nube (Recomendado si no tienes Android Studio)

El proyecto incluye el archivo de flujo de trabajo `.github/workflows/build_apk.yml`. Con este método, los servidores de GitHub compilan la APK de forma gratuita en menos de 3 minutos.

### Pasos:
1. Crea un repositorio en tu cuenta de GitHub (puede ser **Público** o **Privado**).
2. Sube la carpeta del proyecto a GitHub ejecutando en la consola de tu computadora:
   ```powershell
   cd c:\Users\mika\Downloads\camarastreaming
   git init
   git add .
   git commit -m "Initial commit: Telepresence Robot with Flutter App and Backend"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git
   git push -u origin main
   ```
3. En la página de tu repositorio en GitHub:
   - Haz clic en la pestaña **Actions** (en la barra superior).
   - Verás la tarea **"Compilar APK Robot Control"** ejecutándose.
4. Cuando termine (aparecerá un check verde ✅):
   - Haz clic sobre la ejecución completada.
   - En la sección inferior **Artifacts**, verás el enlace de descarga: **`RobotControl-Release-APK`**.
5. Descarga el archivo `.zip`, descomprímelo y transfiere el archivo `app-release.apk` a tu teléfono Android (o descárgalo directamente desde el navegador de tu teléfono).
6. Instálalo en tu smartphone (activa "Instalar apps de fuentes desconocidas" si Android lo solicita).

---

## Método B: Compilación Local en tu PC

Si prefieres compilar directamente en tu ordenador con Windows:

### Requisitos Previos:
1. **Flutter SDK:**
   - Descarga Flutter desde [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows).
   - Extrae el archivo en `C:\flutter`.
   - Añade `C:\flutter\bin` a la variable de entorno `PATH` de Windows.
2. **Android Studio y SDK:**
   - Descarga e instala Android Studio.
   - Abre `SDK Manager` e instala:
     - Android SDK Platform 34
     - Android SDK Command-line Tools (latest)
3. **Aceptar Licencias de Android:**
   ```powershell
   flutter doctor --android-licenses
   ```

### Comandos de Compilación:
Una vez configurado Flutter, simplemente ejecuta:
```powershell
# Opción 1: Mediante el script automatizado
.\scripts\build_apk.ps1 -Mode release

# Opción 2: Directamente con Flutter CLI
cd mobile_app
flutter pub get
flutter build apk --release --no-tree-shake-icons
```

El archivo `.apk` resultante se generará en:
`mobile_app/build/app/outputs/flutter-apk/app-release.apk`

---

## Pruebas Inmediatas en la APK

Una vez instalada la app en tu teléfono:
1. Al abrir la app, presiona **"INICIAR"** en la pantalla Splash.
2. Presiona **"INICIAR SESIÓN"** (puedes usar las credenciales por defecto o modo local).
3. En la lista de robots, toca **"PROBAR"** en el banner superior **"Modo Simulador Disponible"**.
4. Podrás mover el **Joystick táctil**, ajustar el **Slider de velocidad**, activar **"MANTENER PARA HABLAR" (PTT)** y pulsar **"STOP"** con respuesta visual inmediata en pantalla horizontal completa.
