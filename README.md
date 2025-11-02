# 🤖 Mobile Automation - Mercado Libre

Mobile test automation project for Mercado Libre mobile application on Android using **Ruby** and **Appium**. This project implements a complete product search and filtering flow with result validation.

## 📋 Project Description

This project automates a functional test case for the Mercado Libre application on Android devices. The script executes a complete flow that includes:

- ✅ Application launch
- ✅ Product search
- ✅ Multiple filter application
- ✅ Result sorting
- ✅ Product data extraction and display

## 🎯 Objective

Validate the complete search and filtering flow in the Mercado Libre application, specifically:

1. Open the Mercado Libre application on an Android device
2. Search for the term "playstation 5" in the search bar
3. Apply condition filter "New" (Nuevos)
4. Apply location filter "Local" (CDMX)
5. Sort results by "highest to lowest price"
6. Extract and display in console the name and price of the first 5 products

## 🚀 Implemented Features

### ✅ Complete Features

- **Appium session initialization**: Automatic connection with Appium server
- **Application launch**: Activation and opening of Mercado Libre
- **Product search**: Automated search with multiple locator handling
- **Filter system**:
  - Condition filter (New)
  - Shipping filter (Local)
  - Price sorting (Highest to lowest)
- **Data extraction**: Product name and price retrieval
- **Detailed logging**: Color-coded log system for better visibility
- **Error handling**: Recovery from failures with multiple localization strategies

### 🔧 Technical Features

- Multiple locator handling (ID, XPath, content-desc)
- Intelligent scrolling for list navigation
- Implicit and explicit waits for synchronization
- Coordinate-based clicks as fallback
- Element validation before interaction

## 📦 Prerequisites

### Base Software
- **Ruby 3.2.9** (recommended using rbenv or rvm)
- **Node.js 20.19.0** (using nvm)
- **NPM 10.8.2**
- **Bundler** for Ruby dependency management

### Automation Tools
- **Appium Server** installed globally
- **Appium Driver UiAutomator2** for Android
- **Appium Driver XCUITest** for iOS (optional)

### Device
- **Physical Android device** with USB debugging enabled
- **Or configured Android emulator**
- **Mercado Libre application** installed

### Additional Tools
- **ADB** (Android Debug Bridge) for device management
- **Appium Doctor** for installation verification (optional)

## 📥 Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Mobile-Automation-Test
```

### 2. Configure Ruby

```bash
# If using rbenv
rbenv install 3.2.9
rbenv local 3.2.9

# If using rvm
rvm install 3.2.9
rvm use 3.2.9
```

### 3. Install Ruby Dependencies

```bash
cd Script
bundle install
```

### 4. Configure Node.js

```bash
# Install nvm if not installed
# See: https://github.com/nvm-sh/nvm#installing-and-updating

# Install Node.js 20.19.0
nvm install 20.19.0
nvm use 20.19.0
```

### 5. Install Appium

```bash
# With nvm activated
npm install -g appium

# Install necessary drivers
appium driver install uiautomator2  # For Android
appium driver install xcuitest      # For iOS (optional)
```

### 6. Verify Installation (Optional)

```bash
npm install -g @appium/doctor
appium-doctor
```

## ⚙️ Configuration

### For Physical Android Device

1. **Enable Developer Options** on your Android device
2. **Enable USB Debugging**
3. **Connect the device** via USB
4. **Verify connection**:
   ```bash
   adb devices
   ```
5. **Get the UDID** of the device from the output above
6. **Update the UDID** in `Script/Appium.rb` line 25:
   ```ruby
   'appium:udid': 'YOUR_UDID_HERE',  # Replace with your UDID
   ```

### For Android Emulator

1. **Create an emulator** in Android Studio
2. **Start the emulator**
3. **Verify that the UDID** is `emulator-5554` (by default)
4. If different, update in `Script/Appium.rb` line 25

### Advanced Configuration

You can customize other parameters in `Script/Appium.rb`:

- **Appium Port** (line 43):
  ```ruby
  server_url = 'http://localhost:4723'  # Change port if necessary
  ```

- **Command timeout** (line 29):
  ```ruby
  'appium:newCommandTimeout': 300,  # Seconds
  ```

## 🏃‍♂️ Usage

### Method 1: Automatic Script (Recommended)

From the `Script` directory:

```bash
cd Script
./run_appium.sh
```

This script:
- ✅ Automatically switches to Node.js 20.19.0 using nvm
- ✅ Starts Appium Server in the background
- ✅ Executes the Ruby script
- ✅ Cleans up processes on completion

### Method 2: Manual Execution

**Terminal 1 - Start Appium Server:**
```bash
cd Script
nvm use 20.19.0
appium server --port 4723
```

**Terminal 2 - Execute Script:**
```bash
cd Script
ruby Appium.rb
```

## 📁 Project Structure

```
Mobile-Automation-Test/
├── README.md                    # This file - Main documentation
├── Script/                      # Main project directory
│   ├── Appium.rb               # Main automation script
│   ├── Gemfile                 # Ruby dependencies
│   ├── Gemfile.lock            # Locked gem versions
│   ├── run_appium.sh           # Automatic execution script
│   ├── appium_capabilities.json # Capabilities configuration (reference)
│   └── README.md               # Detailed technical documentation
└── .ruby-version               # Required Ruby version
```

## 🔍 Technical Details

### Used Versions

- **Ruby**: 3.2.9
- **Node.js**: 20.19.0
- **NPM**: 10.8.2
- **Appium**: Latest stable version
- **appium_lib**: ~> 12.0
- **colorize**: ~> 0.8.1

### Main Dependencies

- `appium_lib`: Ruby library for Appium
- `logger`: Ruby logging system
- `colorize`: Console colors for better readability

### Code Architecture

The script is structured in a `MercadoLibreAppOpener` class that encapsulates all automation logic:

- **Initialization**: Capabilities and logger configuration
- **Session management**: Appium session start and end
- **Interactions**: Methods for each flow step
- **Data extraction**: UI element parsing to obtain information
- **Error handling**: Recovery with multiple strategies

## 📊 Execution Flow

1. **Start**: Connects with Appium Server
2. **Launch**: Activates and opens Mercado Libre application
3. **Search**: Locates search bar and searches for "playstation 5"
4. **Filters**: Opens filter panel
5. **Filter application**:
   - Condition: "New"
   - Shipping: "Local"
   - Sorting: "Highest price"
6. **Apply**: Clicks "View results"
7. **Extraction**: Gets first 5 products with name and price
8. **Close**: Closes session cleanly

## 📝 Logs and Output

The script generates detailed logs with a color system:

- 🔵 **Blue/Cyan**: General information and process steps
- 🟢 **Green**: Successful operations
- 🟡 **Yellow**: Warnings (elements not found, but continues)
- 🔴 **Red**: Critical errors

### Example Output

```
==> Appium session active - App opened
==> Mercado Libre opened successfully
==> Search performed successfully
==> 'New' filter applied successfully
==> 'Local' filter applied successfully
==> 'Highest price' filter applied successfully
Extracting data from the first 5 results...
   -> Product 1: PlayStation 5 - $12,999.00
   -> Product 2: PlayStation 5 Digital Edition - $10,999.00
   ...
```

## 🐛 Troubleshooting

### Error: "Device not found"

**Solution:**
```bash
# Verify device connection
adb devices

# If it doesn't appear, try:
adb kill-server
adb start-server
adb devices
```

- Verify that the UDID is correct in `Appium.rb`
- Ensure USB debugging is enabled
- Try with a different USB cable

### Error: "App not installed"

**Solution:**
- Install Mercado Libre from Play Store
- Verify package name: `com.mercadolibre`
- Verify app is installed: `adb shell pm list packages | grep mercadolibre`

### Error: "Appium Server not running"

**Solution:**
```bash
# Verify Appium is installed
appium --version

# Verify port 4723 is free
lsof -i :4723

# If occupied, kill the process
kill -9 <PID>

# Or use another port in Appium.rb
```

### Error: "Node version mismatch"

**Solution:**
```bash
# Make sure to use the correct version
nvm use 20.19.0

# If not installed
nvm install 20.19.0

# Verify version
node --version
```

### Error: "Element not found"

**Solution:**
- Mercado Libre application may have changed its UI
- Verify locators in the script
- Use `adb shell uiautomator dump` to inspect current UI
- Review logs to see which locator failed

## 🎯 Acceptance Criteria

- ✅ Test executes without manual intervention
- ✅ Script correctly identifies UI elements on Android
- ✅ Filters are applied according to specification
- ✅ Names and prices of first 5 products are displayed in console
- ✅ Sorting is applied correctly (highest to lowest price)

## 📈 Future Improvements (Pending)

- [ ] Generate execution report
- [ ] Include screenshots for each step
- [ ] Full iOS support (partially implemented)

## 👤 Author

**Oliver Olvera**

## 📄 License

This project is for educational and demonstration purposes.

## 📞 Support

If you encounter issues:

1. Review the [Troubleshooting](#-troubleshooting) section
2. Consult `Script/README.md` for detailed technical documentation
3. Verify that all dependencies are correctly installed
4. Review Appium logs for more details
5. Consult [official Appium documentation](https://appium.io/docs/en/latest/)

## 🔗 Useful Links

- [Appium Documentation](https://appium.io/docs/en/latest/)
- [Appium Ruby Client](https://github.com/appium/ruby_lib)
- [Android UI Automator](https://developer.android.com/training/testing/ui-automator)
- [Ruby Documentation](https://www.ruby-lang.org/en/documentation/)

---

**Last updated**: November 2025
