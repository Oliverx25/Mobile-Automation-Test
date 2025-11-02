#!/bin/bash

# Script para ejecutar Appium con nvm y abrir Mercado Libre
# Autor: Oliver Olvera
# Fecha: 2024

echo "--> Iniciando script de automatización de Mercado Libre"
echo "=================================================="

# Cargar nvm correctamente (nvm es una función de shell, no un comando)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Verificar que nvm esté cargado
if ! command -v nvm &> /dev/null && [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "/// nvm no está instalado. Por favor instala nvm primero."
    echo "--> Instrucciones: https://github.com/nvm-sh/nvm#installing-and-updating"
    exit 1
fi

# Usar Node.js 20.19.0
echo "--> Cambiando a Node.js 20.19.0..."
nvm use 20.19.0 > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "/// Error al cambiar a Node.js 20.19.0"
    echo "--> Intenta instalar la versión: nvm install 20.19.0"
    exit 1
fi

# Verificar versión de Node.js
NODE_VERSION=$(node --version)
echo "==> Versión de Node.js: $NODE_VERSION"

# Verificar que Appium esté instalado
echo "--> Verificando instalación de Appium..."
if ! command -v appium &> /dev/null; then
    echo "/// Appium no está instalado globalmente"
    echo "--> Instala Appium con: npm install -g appium"
    exit 1
fi

# Verificar versión de Appium
APPIUM_VERSION=$(appium --version 2>/dev/null || echo "desconocida")
echo "==> Versión de Appium: $APPIUM_VERSION"

# Verificar que el servidor de Appium no esté corriendo
echo "--> Verificando si Appium Server ya está corriendo..."
if pgrep -f "appium" > /dev/null; then
    echo "/// Appium Server ya está corriendo"
    echo "--> Matando procesos existentes..."
    pkill -f "appium"
    sleep 2
fi

# Crear directorio para logs si no existe
LOG_DIR="$(pwd)/logs"
mkdir -p "$LOG_DIR"
APPIUM_LOG="$LOG_DIR/appium_server.log"

# Iniciar Appium Server en background con logs redirigidos
echo "--> Iniciando Appium Server en segundo plano..."
echo "--> Logs del servidor se guardan en: $APPIUM_LOG"
appium > "$APPIUM_LOG" 2>&1 &
APPIUM_PID=$!

# Esperar a que Appium se inicie
echo "--> Esperando a que Appium Server se inicie..."
sleep 5

# Verificar que Appium esté corriendo
if ! pgrep -f "appium" > /dev/null; then
    echo "/// Error: Appium Server no se inició correctamente"
    echo "--> Revisa los logs en: $APPIUM_LOG"
    exit 1
fi

echo "==> Appium Server iniciado correctamente (PID: $APPIUM_PID)"
echo ""

# Instalar dependencias de Ruby si es necesario
if [ ! -f "Gemfile.lock" ]; then
    echo "--> Instalando dependencias de Ruby..."
    bundle install > /dev/null 2>&1
fi

# Ejecutar el script de Ruby (esta será la única salida visible)
ruby Appium.rb

# Capturar el resultado
SCRIPT_RESULT=$?

# Limpiar: matar Appium Server
echo ""
echo "--> Limpiando procesos..."
kill $APPIUM_PID 2>/dev/null
sleep 2

# Verificar que se cerró correctamente
if pgrep -f "appium" > /dev/null; then
    echo "--> Forzando cierre de Appium Server..."
    pkill -f "appium"
    sleep 1
fi

# Mostrar resultado final
if [ $SCRIPT_RESULT -eq 0 ]; then
    echo "==> Script ejecutado exitosamente"
else
    echo "/// El script falló con código de salida: $SCRIPT_RESULT"
fi

echo "--> Script finalizado"
echo "--> Logs del servidor Appium disponibles en: $APPIUM_LOG"
