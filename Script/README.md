# Automatización - Mercado Libre

Script de automatización para la aplicación de Mercado Libre en dispositivos Android utilizando Appium y Ruby.

## Requisitos Previos

1. **Node.js 20.19.0** (usando nvm)
2. **Appium Server** instalado globalmente
3. **Ruby 3.2.9** (recomendado usar rbenv o rvm)
4. **Dispositivo Android** conectado o emulador
5. **Aplicación de Mercado Libre** instalada en el dispositivo

## Instalación

### 1. Instalar dependencias de Ruby

```bash
bundle install
```

### 2. Verificar instalación de Appium

```bash
# Con nvm activado
nvm use 20.19.0
npm install -g appium
```

### 3. Instalar drivers de Appium (si es necesario)

```bash
appium driver install uiautomator2
```

## Configuración del Dispositivo

### Para Dispositivo Físico

1. Activar **Opciones de desarrollador** en tu Android
2. Activar **Depuración USB**
3. Conectar el dispositivo via USB
4. Verificar conexión: `adb devices`
5. Cambiar el UDID en `Appium.rb` línea 25:
   ```ruby
   'appium:udid': 'TU_UDID_AQUI', # Reemplaza con el UDID de tu dispositivo
   ```

### Para Emulador

1. Crear un emulador Android en Android Studio
2. Iniciar el emulador
3. Verificar que el UDID sea `emulator-5554` (por defecto)

## Ejecución

### Método 1: Script Automático (Recomendado)

```bash
./run_appium.sh
```

Este script:
- Cambia automáticamente a Node.js 20.19.0 usando nvm
- Inicia Appium Server en segundo plano
- Ejecuta el script de Ruby
- Limpia los procesos al finalizar

### Método 2: Manual

```bash
# Terminal 1: Iniciar Appium Server
nvm use 20.19.0
appium

# Terminal 2: Ejecutar script
ruby Appium.rb
```

## Estructura del Proyecto

```
Script/
├── Appium.rb          # Script principal de automatización
├── Gemfile            # Dependencias de Ruby
├── run_appium.sh      # Script de ejecución automática
├── appium_capabilities.json # Configuración de capabilities (referencia)
└── README.md          # Este archivo
```

## Configuración Avanzada

### Cambiar Dispositivo

Edita la línea 25 en `Appium.rb`:
```ruby
'appium:udid': 'TU_UDID_AQUI',
```

### Cambiar Timeout

Edita la línea 29 en `Appium.rb`:
```ruby
'appium:newCommandTimeout': 300, # Segundos
```

### Cambiar Puerto de Appium

Edita la línea 43 en `Appium.rb`:
```ruby
server_url = 'http://localhost:4723' # Cambia el puerto si es necesario
```

## Solución de Problemas

### Error: "Device not found"

- Verifica que el dispositivo esté conectado: `adb devices`
- Asegúrate de que el UDID sea correcto
- Verifica que la depuración USB esté activada

### Error: "App not installed"

- Instala Mercado Libre en tu dispositivo
- Verifica que el package name sea correcto: `com.mercadolibre`

### Error: "Appium Server not running"

- Verifica que Appium esté instalado: `appium --version`
- Asegúrate de que el puerto 4723 esté libre
- Revisa los logs de Appium para más detalles

### Error: "Node version mismatch"

- Asegúrate de usar Node.js 20.19.0: `nvm use 20.19.0`
- Verifica que nvm esté instalado correctamente

## Funcionalidad Actual

El script ejecuta el siguiente flujo:

1. Inicia una sesión de Appium
2. Abre la aplicación de Mercado Libre
3. Busca "playstation 5" en la barra de búsqueda
4. Aplica filtro de condición "Nuevos"
5. Aplica filtro de envíos "Local"
6. Ordena resultados por "Mayor precio"
7. Extrae y muestra los primeros 5 productos con nombre y precio
8. Cierra la sesión limpiamente

## Logs

El script genera logs detallados con colores:
- **Azul**: Información general
- **Verde**: Operaciones exitosas
- **Amarillo**: Advertencias
- **Rojo**: Errores

Los logs del servidor Appium se guardan en el directorio `logs/appium_server.log` cuando se ejecuta con el script automático.

## Soporte

Si tienes problemas:

1. Revisa los logs de error
2. Verifica la configuración del dispositivo
3. Asegúrate de que todas las dependencias estén instaladas
4. Consulta la documentación oficial de Appium
