# Automation Project - Mercado Libre

This project contains a script to open the Mercado Libre application on an Android device using Appium.

## 📋 Prerequisites

1. **Node.js 20.19.0** (using nvm)
2. **Appium Server** installed globally
3. **Ruby 3.2.9** (recommended using rbenv or rvm)
4. **Android device** connected or emulator
5. **Mercado Libre application** installed on the device

## 🚀 Installation

### 1. Install Ruby dependencies
```bash
bundle install
```

### 2. Verify Appium installation
```bash
# With nvm activated
nvm use 20.19.0
npm install -g appium
```

### 3. Install Appium drivers (if necessary)
```bash
appium driver install uiautomator2
```

## 📱 Device Configuration

### For Physical Device:
1. Enable **Developer options** on your Android
2. Enable **USB debugging**
3. Connect the device via USB
4. Verify connection: `adb devices`
5. Change the UDID in `Appium.rb` line 25:
   ```ruby
   'appium:udid': 'YOUR_UDID_HERE', # Replace with your device's UDID
   ```

### For Emulator:
1. Create an Android emulator in Android Studio
2. Start the emulator
3. Verify that the UDID is `emulator-5554` (default)

## 🏃‍♂️ Execution

### Method 1: Automatic Script (Recommended)
```bash
./run_appium.sh
```

This script:
- Automatically switches to Node.js 20.19.0 using nvm
- Starts Appium Server
- Executes the Ruby script
- Cleans up processes on completion

### Method 2: Manual
```bash
# Terminal 1: Start Appium Server
nvm use 20.19.0
appium server --port 4723

# Terminal 2: Execute script
ruby Appium.rb
```

## 📁 Project Structure

```
Automation Project with Appium/
├── Appium.rb          # Main automation script
├── Gemfile            # Ruby dependencies
├── run_appium.sh      # Automatic execution script
└── README.md          # This file
```

## 🔧 Advanced Configuration

### Change Device
Edit line 25 in `Appium.rb`:
```ruby
'appium:udid': 'YOUR_UDID_HERE',
```

### Change Timeout
Edit line 30 in `Appium.rb`:
```ruby
'appium:newCommandTimeout': 60, # Seconds
```

### Change Appium Port
Edit line 47 in `Appium.rb`:
```ruby
server_url = 'http://localhost:4723' # Change port if necessary
```

## 🐛 Troubleshooting

### Error: "Device not found"
- Verify the device is connected: `adb devices`
- Make sure the UDID is correct
- Verify USB debugging is enabled

### Error: "App not installed"
- Install Mercado Libre on your device
- Verify the package name is correct: `com.mercadolibre`

### Error: "Appium Server not running"
- Verify Appium is installed: `appium --version`
- Make sure port 4723 is free
- Review Appium logs for more details

### Error: "Node version mismatch"
- Make sure to use Node.js 20.19.0: `nvm use 20.19.0`
- Verify nvm is correctly installed

## 📝 Logs

The script generates detailed logs with colors:
- 🔵 **Blue**: General information
- 🟢 **Green**: Successful operations
- 🟡 **Yellow**: Warnings
- 🔴 **Red**: Errors

## 🎯 Current Functionality

The current script:
1. ✅ Starts an Appium session
2. ✅ Opens the Mercado Libre application
3. ✅ Verifies the app opened correctly
4. ✅ Keeps the session open for 10 seconds
5. ✅ Closes the session cleanly

## 🔮 Next Steps

- [ ] Add more interactions with the app
- [ ] Implement product search
- [ ] Add element validations
- [ ] Create execution reports
- [ ] Support for multiple devices

## 📞 Support

If you have problems:
1. Review error logs
2. Verify device configuration
3. Make sure all dependencies are installed
4. Consult the official Appium documentation
