#!/usr/bin/env bash
set -e

# Descargar Flutter estable (solo durante el build en Netlify)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PWD/flutter/bin:$PATH"

# Activar web y construir
flutter doctor -v
flutter config --enable-web
flutter pub get
flutter build web --release
