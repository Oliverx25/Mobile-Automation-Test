# Automatización Mobile - Mercado Libre

Proyecto de automatización de pruebas para la aplicación móvil de Mercado Libre en Android utilizando **Ruby** y **Appium**. Implementa un flujo completo de búsqueda y filtrado de productos con validación de resultados.

## Descripción del Proyecto

Este proyecto automatiza un caso de prueba funcional para la aplicación de Mercado Libre en dispositivos Android. El script ejecuta un flujo completo que incluye:

- Apertura de la aplicación
- Búsqueda de productos
- Aplicación de múltiples filtros
- Ordenamiento de resultados
- Extracción y visualización de datos de productos

## Objetivo

Validar el flujo completo de búsqueda y filtrado en la aplicación de Mercado Libre:

1. Abrir la aplicación de Mercado Libre en un dispositivo Android
2. Buscar el término "playstation 5" en la barra de búsqueda
3. Aplicar filtro de condición "Nuevos"
4. Aplicar filtro de ubicación "Local" (CDMX)
5. Ordenar resultados por "mayor a menor precio"
6. Extraer y mostrar en consola el nombre y precio de los primeros 5 productos

## Requisitos Previos

### Software Base
- **Ruby 3.2.9** (recomendado usar rbenv o rvm)
- **Node.js 20.19.0** (usando nvm)
- **NPM 10.8.2**
- **Bundler** para gestión de dependencias Ruby

### Herramientas de Automatización
- **Appium Server** instalado globalmente
- **Appium Driver UiAutomator2** para Android
- **Appium Driver XCUITest** para iOS (opcional)

### Dispositivo
- Dispositivo Android físico con depuración USB activada, o emulador Android configurado
- Aplicación de Mercado Libre instalada

### Herramientas Adicionales
- **ADB** (Android Debug Bridge) para gestión de dispositivos
- **Appium Doctor** para verificación de instalación (opcional)

## Instalación

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd Mobile-Automation-Test
```

### 2. Configurar Ruby

```bash
# Si usas rbenv
rbenv install 3.2.9
rbenv local 3.2.9

# Si usas rvm
rvm install 3.2.9
rvm use 3.2.9
```

### 3. Instalar Dependencias de Ruby

```bash
cd Script
bundle install
```

### 4. Configurar Node.js

```bash
# Instalar nvm si no está instalado
# Ver: https://github.com/nvm-sh/nvm#installing-and-updating

# Instalar Node.js 20.19.0
nvm install 20.19.0
nvm use 20.19.0
```

### 5. Instalar Appium

```bash
# Con nvm activado
npm install -g appium

# Instalar drivers necesarios
appium driver install uiautomator2  # Para Android
appium driver install xcuitest      # Para iOS (opcional)
```

### 6. Verificar Instalación (Opcional)

```bash
npm install -g @appium/doctor
appium-doctor
```

## Configuración

### Para Dispositivo Físico Android

1. Activar **Opciones de Desarrollador** en tu dispositivo Android
2. Activar **Depuración USB**
3. Conectar el dispositivo vía USB
4. Verificar conexión:
   ```bash
   adb devices
   ```
5. Obtener el UDID del dispositivo de la salida anterior
6. Actualizar el UDID en `Script/Appium.rb` línea 25:
   ```ruby
   'appium:udid': 'TU_UDID_AQUI',  # Reemplaza con tu UDID
   ```

### Para Emulador Android

1. Crear un emulador en Android Studio
2. Iniciar el emulador
3. Verificar que el UDID sea `emulator-5554` (por defecto)
4. Si es diferente, actualizar en `Script/Appium.rb` línea 25

### Configuración Avanzada

Puedes personalizar otros parámetros en `Script/Appium.rb`:

- **Puerto de Appium** (línea 43):
  ```ruby
  server_url = 'http://localhost:4723'  # Cambiar puerto si es necesario
  ```

- **Timeout de comandos** (línea 29):
  ```ruby
  'appium:newCommandTimeout': 300,  # Segundos
  ```

## Uso

### Método 1: Script Automático (Recomendado)

Desde el directorio `Script`:

```bash
cd Script
./run_appium.sh
```

Este script:
- Cambia automáticamente a Node.js 20.19.0 usando nvm
- Inicia Appium Server en segundo plano
- Ejecuta el script de Ruby
- Limpia los procesos al finalizar

### Método 2: Ejecución Manual

**Terminal 1 - Iniciar Appium Server:**
```bash
cd Script
nvm use 20.19.0
appium
```

**Terminal 2 - Ejecutar Script:**
```bash
cd Script
ruby Appium.rb
```

## Estructura del Proyecto

```
Mobile-Automation-Test/
├── README.md                    # Documentación principal
├── Script/                      # Directorio principal del proyecto
│   ├── Appium.rb               # Script principal de automatización
│   ├── Gemfile                 # Dependencias de Ruby
│   ├── Gemfile.lock            # Versiones bloqueadas de gemas
│   ├── run_appium.sh           # Script de ejecución automática
│   ├── appium_capabilities.json # Configuración de capabilities (referencia)
│   └── README.md               # Documentación técnica detallada
└── .ruby-version               # Versión de Ruby requerida
```

## Detalles Técnicos

### Versiones Utilizadas

- Ruby: 3.2.9
- Node.js: 20.19.0
- NPM: 10.8.2
- Appium: Última versión estable
- appium_lib: ~> 12.0
- colorize: ~> 0.8.1

### Dependencias Principales

- `appium_lib`: Librería Ruby para Appium
- `logger`: Sistema de logging de Ruby
- `colorize`: Colores en consola para mejor legibilidad

### Arquitectura del Código

El script está estructurado en una clase `MercadoLibreAppOpener` que encapsula toda la lógica de automatización:

- **Inicialización**: Configuración de capabilities y logger
- **Gestión de sesión**: Inicio y cierre de sesión de Appium
- **Interacciones**: Métodos para cada paso del flujo
- **Extracción de datos**: Parsing de elementos UI para obtener información
- **Manejo de errores**: Recuperación con múltiples estrategias

## Flujo de Ejecución

1. **Inicio**: Conecta con Appium Server
2. **Apertura**: Activa y abre la aplicación de Mercado Libre
3. **Búsqueda**: Localiza la barra de búsqueda y busca "playstation 5"
4. **Filtros**: Abre el panel de filtros
5. **Aplicación de filtros**:
   - Condición: "Nuevos"
   - Envíos: "Local"
   - Ordenamiento: "Mayor precio"
6. **Aplicar**: Hace clic en "Ver resultados"
7. **Extracción**: Obtiene los primeros 5 productos con nombre y precio
8. **Cierre**: Cierra la sesión limpiamente

## Logs y Salida

El script genera logs detallados con sistema de colores:

- **Azul/Cyan**: Información general y pasos del proceso
- **Verde**: Operaciones exitosas
- **Amarillo**: Advertencias (elementos no encontrados, pero continúa)
- **Rojo**: Errores críticos

### Ejemplo de Salida

```
==> Sesión de Appium activa - App abierta
==> Mercado Libre abierto correctamente
==> Búsqueda realizada correctamente
==> Filtro 'Nuevo' aplicado correctamente
==> Filtro 'Local' aplicado correctamente
==> Filtro 'Mayor precio' aplicado correctamente
Extrayendo datos de los primeros 5 resultados...
   -> Producto 1: PlayStation 5 - $12,999.00
   -> Producto 2: PlayStation 5 Digital Edition - $10,999.00
   ...
```

## Solución de Problemas

### Error: "Device not found"

**Solución:**
```bash
# Verificar conexión del dispositivo
adb devices

# Si no aparece, probar:
adb kill-server
adb start-server
adb devices
```

- Verificar que el UDID sea correcto en `Appium.rb`
- Asegurar que la depuración USB esté activada
- Probar con un cable USB diferente

### Error: "App not installed"

**Solución:**
- Instalar Mercado Libre desde Play Store
- Verificar el package name: `com.mercadolibre`
- Verificar que la app esté instalada: `adb shell pm list packages | grep mercadolibre`

### Error: "Appium Server not running"

**Solución:**
```bash
# Verificar que Appium esté instalado
appium --version

# Verificar que el puerto 4723 esté libre
lsof -i :4723

# Si está ocupado, matar el proceso
kill -9 <PID>

# O usar otro puerto en Appium.rb
```

### Error: "Node version mismatch"

**Solución:**
```bash
# Asegurarse de usar la versión correcta
nvm use 20.19.0

# Si no está instalada
nvm install 20.19.0

# Verificar versión
node --version
```

### Error: "Element not found"

**Solución:**
- La aplicación de Mercado Libre puede haber cambiado su UI
- Verificar los localizadores en el script
- Usar `adb shell uiautomator dump` para inspeccionar la UI actual
- Revisar los logs para ver qué localizador falló

## Criterios de Aceptación

- El test se ejecuta sin intervención manual
- El script identifica correctamente los elementos UI en Android
- Los filtros se aplican según la especificación
- Se muestran los nombres y precios de los primeros 5 productos en consola
- El ordenamiento se aplica correctamente (mayor a menor precio)

## Mejoras Futuras

- Generar reporte de ejecución
- Incluir capturas de pantalla para cada paso
- Soporte completo para iOS (parcialmente implementado)

## Autor

**Oliver Olvera**

## Licencia

Este proyecto es de uso educativo y de demostración.

## Enlaces Útiles

- [Documentación de Appium](https://appium.io/docs/en/latest/)
- [Appium Ruby Client](https://github.com/appium/ruby_lib)
- [Android UI Automator](https://developer.android.com/training/testing/ui-automator)
- [Ruby Documentation](https://www.ruby-lang.org/en/documentation/)
- [Deepwiki Documentación](https://deepwiki.com/Oliverx25/Mobile-Automation-Test/1-overview)

---

**Última actualización**: Noviembre 2025
