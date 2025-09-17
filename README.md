# SystemInfoWidget for Übersicht

A comprehensive system monitoring widget for [Übersicht](http://tracesof.net/uebersicht/) that displays detailed system information on your macOS desktop.

![SystemInfoWidget Preview](preview.png)

## Features

### System Information
- OS version and kernel details
- Hostname and username
- Uptime tracking
- Shell and terminal detection
- Desktop environment info

### Hardware Monitoring
- CPU model with thread count
- Real-time CPU usage
- Memory usage with percentage
- GPU information
- Display resolution

### Network Monitoring
- All network interfaces with IPs
- WiFi SSID display
- Public IP with location
- Network traffic rates (up/down)
- **Live app network usage** - See which apps are using bandwidth
- Ping latency monitoring
- VPN/Tailscale detection

### Storage Information
- APFS-accurate disk usage
- Available space tracking
- Visual percentage indicator

### Package Management
- Dual Homebrew support (Intel & ARM)
- Package counts (brew, cask, npm, pip)
- Outdated package tracking with caching

### Developer Tools
- Programming language versions (Ruby, Node.js, Python, etc.)
- Version manager detection (asdf, rbenv, nvm)
- Configurable language display

### Power Management
- Battery percentage
- Charging status indicator

## Installation

Installing this widget is super easy! Just follow the steps below:

### Step 1: Install Übersicht
First, you need the Übersicht app itself:
```bash
brew install --cask ubersicht
```
Or download from [http://tracesof.net/uebersicht/](http://tracesof.net/uebersicht/)

### Step 2: Install Required Dependencies
Install all required tools with one command:
```bash
# Install required tools (jq) and recommended font
brew install jq && \
brew tap homebrew/cask-fonts && \
brew install --cask font-iosevka-term-nerd-font
```

### Step 3: Install the Widget

#### Option A: Via Git (Recommended)
```bash
cd ~/Library/Application\ Support/Übersicht/widgets/
git clone https://github.com/konung/ubersicht-SystemInfoWidget.git SystemInfoWidget.widget
```

#### Option B: Manual Download
1. Download the latest release from [GitHub](https://github.com/konung/ubersicht-SystemInfoWidget/releases)
2. Move the downloaded folder to `~/Library/Application Support/Übersicht/widgets/`
3. Rename the folder to `SystemInfoWidget.widget` if needed

### Step 4: Configure the Font in Übersicht
1. Open Übersicht preferences (click the Übersicht icon in menu bar → Preferences)
2. Under "General" tab, set the font to **IosevkaTerm Nerd Font Mono**
3. Adjust font size if needed (recommended: 13-15px)

### Step 5: Refresh and Position
1. Refresh Übersicht (menu bar → Refresh All Widgets)
2. The widget should appear in the top-left corner
3. To adjust position, edit `index.coffee`:
   ```coffee
   position:
     top: 20    # Distance from top
     left: 20   # Distance from left
   ```

### Quick Install Script
For the lazy developers, here's a one-liner that does everything:
```bash
brew install --cask ubersicht && \
brew install jq && \
brew tap homebrew/cask-fonts && \
brew install --cask font-iosevka-term-nerd-font && \
cd ~/Library/Application\ Support/Übersicht/widgets/ && \
git clone https://github.com/konung/ubersicht-SystemInfoWidget.git SystemInfoWidget.widget && \
open -a Übersicht
```

### Verify Installation
After installation, you should see:
- System information with icons (not boxes or `?` characters)
- Real-time updates every 5 seconds
- Network traffic monitoring with app names

If icons appear as boxes, double-check that IosevkaTerm Nerd Font is selected in Übersicht preferences.

## Configuration

Edit `index.coffee` to customize the widget:

### Position
```coffee
position:
  top: 20     # Distance from top
  left: 20    # Distance from left
```

### Display Options
```coffee
display:
  showLogo: false         # ASCII art logo
  showSystemInfo: true    # System details
  showHardware: true      # CPU/Memory
  showNetwork: true       # Network info
  showStorage: true       # Disk usage
  showBattery: true       # Battery status
  showLanguages: true     # Dev languages
  showNetworkApps: true   # App traffic monitoring
  networkAppsCount: 3     # Number of apps to show
```

### Network App Filtering
```coffee
skipNetworkApps: [
  'kernel_task'
  'IPNExtension'
  'mDNSResponder'
  # Add more apps to exclude
]
```

### Appearance
```coffee
appearance:
  backgroundOpacity: 0.85
  backgroundBlur: 10
  borderRadius: 13
  fontSize: 15
  iconFontSize: 18
```

## Requirements

### System Requirements
- macOS 10.14 or later
- [Übersicht](http://tracesof.net/uebersicht/) (widget platform)

### Required Tools
These must be installed for the widget to function:

| Tool | Purpose | Installation |
|------|---------|-------------|
| `jq` | JSON processing | `brew install jq` |
| `curl` | IP geolocation | Pre-installed on macOS |
| `bc` | Math calculations | Pre-installed on macOS |

### Optional but Recommended
- **Nerd Fonts** - For proper icon display (recommended: [IosevkaTerm Nerd Font](https://www.nerdfonts.com/))
  - Without Nerd Fonts, icons will appear as boxes or missing characters
  - Install via Homebrew: `brew tap homebrew/cask-fonts && brew install --cask font-iosevka-term-nerd-font`

### Built-in macOS Tools Used
The widget uses these pre-installed macOS tools:
- **System**: `sw_vers`, `sysctl`, `scutil`, `system_profiler`, `uptime`, `defaults`
- **Network**: `ifconfig`, `networksetup`, `netstat`, `nettop`, `ping`, `route`, `nslookup`
- **Storage**: `diskutil` (for APFS-accurate readings), `df` (fallback)
- **Power**: `pmset` (battery status)
- **Text Processing**: `awk`, `sed`, `grep`, `cut`, `sort`, etc.

### Optional Tool Detection
The widget automatically detects and uses if present:
- **Package Managers**: `brew`, `npm`, `pip`/`pip3`
- **Version Managers**: `asdf`, `rbenv`, `nvm`, `pyenv`
- **Languages**: `ruby`, `node`, `python`, `crystal`, `elixir`, `rust`, `go`, `java`
- **Enhanced Tools**:
  - `gping` - Better ping statistics (`brew install gping`)

## Features in Detail

### Smart Caching
- Brew outdated packages cached for 1 hour
- IP location cached for 5 minutes
- Network traffic tracked continuously

### Dual Homebrew Support
Automatically detects and monitors both:
- Intel Homebrew at `/usr/local/bin/brew`
- ARM Homebrew at `/opt/homebrew/bin/brew`

### Real-time Network Traffic
- Shows current upload/download rates
- Per-app bandwidth monitoring
- Configurable app filtering

## Customization

### Adding Programming Languages
Edit the `languages` array in `index.coffee`:
```coffee
languages: [
  'ruby'
  'nodejs'
  'python'
  'rust'
  'go'
  # Add more as needed
]
```

### Changing Icons
The widget uses Nerd Font icons. You can customize them in the `icons` section:
```coffee
icons:
  os: ''        # Apple logo
  cpu: ''       # CPU icon
  memory: '󰍛'    # RAM icon
  # ... more icons
```

## Troubleshooting

### Widget not displaying
- Check that Übersicht is running
- Verify the widget is in the correct directory
- Check Console.app for error messages

### Missing icons
- Install a Nerd Font (recommended: IosevkaTerm Nerd Font)
- Set the font in Übersicht preferences

### Network apps not showing
- The widget uses `nettop` for per-app bandwidth monitoring
- `nettop` doesn't require special permissions for basic functionality
- Only actively transferring apps will appear in the list
- System processes can be filtered via `skipNetworkApps` configuration

### Permission Issues
- If you see permission errors, the widget will still function but some features may be limited
- Network traffic totals will always work as they use `netstat` which doesn't require special permissions

## License

MIT License - feel free to modify and distribute

## Contributing

Pull requests are welcome! Please feel free to submit issues or improvements.


## Credits

Inspired by Übersicht widgets NetFullSysInfo and neofetch.
