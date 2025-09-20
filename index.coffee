# ==============================================================================
# SystemInfoWidget - Advanced System Monitor for Übersicht
# ==============================================================================
# Version: 3.1.1
# Author: Nick Gorbikoff
# Repository: https://github.com/konung/ubersicht-SystemInfoWidget
#
# A comprehensive system monitoring widget that displays:
# - System information (OS, kernel, uptime, shell)
# - Hardware info (CPU, memory usage)
# - Network interfaces and traffic
# - Storage usage with APFS support
# - Development tools and language versions
# - Battery and Time Machine status
# ==============================================================================

# ==============================================================================
# CONFIGURATION SECTION
# ==============================================================================

config =
  # ----------------------------------------------------------------------------
  # Widget Metadata
  # ----------------------------------------------------------------------------
  version: '3.1.1'
  refreshFrequency: 5000  # Update interval in milliseconds (2.5 seconds)

  # ----------------------------------------------------------------------------
  # Widget Position
  # ----------------------------------------------------------------------------
  position:
    top: 20         # Distance from top of screen (pixels)
    left: 20        # Distance from left of screen (pixels)
    right: 'auto'   # Distance from right (use 'auto' to position from left)
    bottom: 'auto'  # Distance from bottom (use 'auto' to position from top)

  # ----------------------------------------------------------------------------
  # Visual Appearance
  # ----------------------------------------------------------------------------
  appearance:
    backgroundOpacity: 0.8
    backgroundBlur: 10
    borderRadius: 13
    padding: 20
    fontSize: 15
    iconFontSize: 20  # Font size for Nerd Font icons
    # fontFamily: 'IosevkaTerm Nerd Font Mono,monospace'
    fontFamily: 'Iosevka Term SS09,IosevkaTerm Nerd Font Mono,monospace'
    boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37)'
    # Color scheme (RGB values)
    colors:
      background: '20, 20, 20'
      text: '255, 255, 255'
      accent: '106, 196, 255'
      success: '152, 195, 121'
      warning: '229, 192, 123'
      danger: '224, 108, 117'
      muted: '150, 150, 150'

  # ----------------------------------------------------------------------------
  # Layout Settings
  # ----------------------------------------------------------------------------
  layout:
    columnGap: 30           # Gap between columns
    infoGroupGap: 15       # Gap between info groups
    networkLabelWidth: 200  # Width for network interface labels
    column1Width: 200      # First column min width (logo)
    column2Width: 350      # Second column min width
    column3Width: 350      # Third column min width
    column4Width: 200      # Fourth column min width (Dev/Software)
    logoFontSize: 20       # Logo font size
    logoLineHeight: 1.2    # Line height for logo text
    defaultLabelWidth: 100  # Default width for all labels
    defaultLabelTextAlign: 'justify'  # Default text alignment for labels
    labelMinWidth: 150     # Default label min width (deprecated, use defaultLabelWidth)
    labelMarginRight: 10   # Space after labels
    labelOpacity: 0.7      # Opacity for labels
    sectionHeaderMargin: 0  # Margin below section headers
    separatorMargin: 10    # Margin around separators
    separatorOpacity: 0.9  # Opacity for separator lines
    separatorMinLength: 50 # Minimum length for separator calculation
    infoSectionGap: 8      # Gap inside info sections
    infoGroupLineGap: 1    # Gap between lines in info groups
    infoLineHeight: 1.1    # Line height for info lines

  # ----------------------------------------------------------------------------
  # Performance Thresholds (for color coding)
  # ----------------------------------------------------------------------------
  thresholds:
    cpuWarning: 60
    cpuDanger: 80
    memoryWarning: 60
    memoryDanger: 80
    diskWarning: 60
    diskDanger: 80
    batteryLow: 20
    batteryWarning: 40
    pingGood: 50
    pingWarning: 100

  # ----------------------------------------------------------------------------
  # Display Settings - Toggle sections on/off
  # ----------------------------------------------------------------------------
  display:
    showLogo: false        # Show/hide ASCII art logo
    showSystemInfo: true
    showHardware: true
    showNetwork: true
    showStorage: true
    showBattery: true
    showLanguages: true    # Show programming language versions
    showDev: true          # Show Dev/Software section
    showNetworkApps: true  # Show apps using network traffic
    showDebugFooter: false # Show debug footer with timing info (impacts performance)
    networkAppsCount: 3    # Number of top traffic apps to show (1-5)
    # Apps to skip in network monitoring (common system processes)
    skipNetworkApps: [
      'kernel_task'
      'IPNExtension'
      'mDNSResponder'
      'trustd'
      'nsurlsessiond'
    ]
    privacyMode: false     # Hide sensitive information
    compactMode: false     # Use compact layout (not implemented)

  # ----------------------------------------------------------------------------
  # Programming Languages to Display
  # ----------------------------------------------------------------------------
  # Comment out languages you don't want to see
  languages: [
    'ruby'
    'python'
    'nodejs'
    'crystal'
    'bun'
    'elixir'
    'nim'
  ]

  # ----------------------------------------------------------------------------
  # Icons (Nerd Font icons - requires Nerd Font installation)
  # ----------------------------------------------------------------------------
  icons:
    os: ''           # 🍎 Apple logo (Nerd Font)
    host: ''         # 🖥️ Host machine (Nerd Font)
    kernel: ''       # 🔧 Kernel (Nerd Font)
    uptime: ''       # ⏱️ Uptime (Nerd Font)
    shell: ''        # 🐚 Shell (Nerd Font)
    terminal: ''     # 💻 Terminal (Nerd Font)
    brew: ''         # 🍺 Homebrew (Nerd Font)
    languages: ''    # 📝 Programming languages (Nerd Font code)
    ruby: ''         # 💎 Ruby (Nerd Font)
    nodejs: ''       # 📦 Node.js (Nerd Font)
    bun: '󰙯'          # 🍞 Bun (Nerd Font)
    nim: '󰒲'          # 🦕 Nim (Nerd Font)
    python: ''       # 🐍 Python (Nerd Font)
    crystal: ''      # 💎 Crystal (Nerd Font)
    elixir: ''       # 💧 Elixir (Nerd Font)
    rust: ''         # 🦀 Rust (Nerd Font)
    go: ''           # 🐹 Go (Nerd Font)
    java: ''         # ☕ Java (Nerd Font)
    php: ''          # 🐘 PHP (Nerd Font)
    swift: ''        # 🦉 Swift (Nerd Font)
    kotlin: ''       # 🅺 Kotlin (Nerd Font)
    typescript: 'ﯤ'   # 📘 TypeScript (Nerd Font)
    javascript: ''   # 📜 JavaScript (Nerd Font)
    c: ''            # 🔤 C (Nerd Font)
    cpp: ''          # ➕ C++ (Nerd Font)
    csharp: ''       # 💻 CSharp (Nerd Font)
    dart: ''         # 🎯 Dart (Nerd Font)
    lua: ''          # 🌙 Lua (Nerd Font)
    perl: ''         # 🐪 Perl (Nerd Font)
    haskell: ''      # λ Haskell (Nerd Font)
    scala: ''        # 🔴 Scala (Nerd Font)
    clojure: ''      # 🍀 Clojure (Nerd Font)
    cpu: ''          # 🧠 CPU (Nerd Font)
    gpu: 'ﮫ'          # 🎮 GPU (Nerd Font)
    memory: ''       # 🧩 Memory (Nerd Font)
    disk: '󰋊'         # 💾 Disk (Nerd Font)
    diskUsage: '󱁌'    # 💾 Disk (Nerd Font)
    ethernet: '󰈀'     # 🔌 Ethernet (Nerd Font)
    wifi: ''         # 📶 Wi-Fi (Nerd Font)
    wifiOff: '󱚼'      # 📵 Wi-Fi off (Nerd Font)
    localIp: ''      # 🏠 Local IP (Nerd Font - home)
    docker: ''       # 🐳 Docker (Nerd Font)
    bridge: ''       # 🌉 Bridge network (Nerd Font)
    vm: ''           # 📦 Virtual Machine (Nerd Font)
    parallels: ''    # 🔷 Parallels (Nerd Font)
    virtualbox: ''   # 📦 VirtualBox (Nerd Font)
    tailscale: '󰖂'    # 🔐 Tailscale (Nerd Font)
    vpn: ''          # 🔒 VPN (Nerd Font)
    hotspot: ''      # 📡 Hotspot (Nerd Font)
    airdrop: ''      # 📤 AirDrop (Nerd Font - share)
    publicIp: ''     # 🌐 Public IP (Nerd Font)
    publicLocation: ''     # 📍 Location (Nerd Font)
    isp: ''          # 🏢 ISP/Organization (Nerd Font)
    ping: '󱦂'         # 📡 Ping (Nerd Font)
    traffic: ''      # 📊 Network traffic (Nerd Font)
    battery: ''      # 🔋 Battery (Nerd Font)
    batteryCharging: '' # ⚡ Battery charging (Nerd Font)
    batteryLow: ''   # 🪫 Battery low (Nerd Font)
    resolution: ''   # Display resolution (Nerd Font - monitor)
    desktop: ''      # 🖼️ Desktop Environment (Nerd Font - window maximize)
    wm: ''           # 🪟 Window Manager (Nerd Font - window restore)
    theme: '󰔎'        # 🎨 Theme (Nerd Font - palette)
    user: ''         # 👤 User (Nerd Font - user circle)
    default: ''      # 🔌 Default/Unknown (Nerd Font - network wired)
    backup: '󰁯'       # 🕑 Backup (Nerd Font - time)

  # ----------------------------------------------------------------------------
  # Progress Bar Settings
  # ----------------------------------------------------------------------------
  progressBar:
    filled: '■'       # Filled portion of progress bar (solid square)
    empty: '□'        # Empty portion of progress bar (empty square)
    width: 20         # Total width of progress bar in characters

  # ----------------------------------------------------------------------------
  # ASCII Art Logo (displayed when showLogo is true)
  # ----------------------------------------------------------------------------
  # Logo source: https://emojicombos.com/apple
  logo: [
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀  "
    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⡿⠀⠀⠀⠀⠀⠀ "
    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀ "
    " ⠀⠀⠀⢀⣠⣤⣤⣤⣀⣀⠈⠋⠉⣁⣠⣤⣬⣤⣀⡀⠀⠀ "
    " ⠀⢠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀ "
    " ⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀ "
    " ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀ "
    " ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀ "
    " ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀ "
    " ⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣀ "
    " ⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁ "
    " ⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀ "
    " ⠀⠀⠀⠈⠙⢿⣿⣿⣿⠿⠟⠛⠻⠿⣿⣿⣿⡿⠋⠀⠀⠀ "
  ]

# ==============================================================================
# WIDGET IMPLEMENTATION
# ==============================================================================

# ------------------------------------------------------------------------------
# Shell Command - Executes the system info collection script
# ------------------------------------------------------------------------------
command: "MEASURE_TIME=#{if config.display.showDebugFooter then 'true' else 'false'} NETWORK_APPS_COUNT=#{config.display.networkAppsCount} SKIP_NETWORK_APPS='#{config.display.skipNetworkApps.join(',')}' SystemInfoWidget.widget/system-info.sh"

# ------------------------------------------------------------------------------
# Refresh Frequency - How often to update the widget
# ------------------------------------------------------------------------------
refreshFrequency: config.refreshFrequency

# ------------------------------------------------------------------------------
# Render Method - Initial widget HTML structure
# ------------------------------------------------------------------------------
render: ->

  # Conditionally include the logo column
  logoColumn = if config.display.showLogo
    """
    <div class="column column-1">
      <div class="logo-section" id="logo"></div>
    </div>
    """
  else
    ""

  # Conditionally include the debug footer
  debugFooter = if config.display.showDebugFooter
    """
    <div class="debug-footer" id="debugFooter">
      <span>v#{config.version}</span>
      <span> | </span>
      <span id="generation-time">--ms</span>
      <span> | </span>
      <span>↻ #{config.refreshFrequency}ms</span>
    </div>
    """
  else
    ""

  # Return the complete widget HTML
  """
  <div class="widget-wrapper" style="
    position: fixed;
    top: #{config.position.top}px;
    left: #{config.position.left}px;
    right: #{config.position.right};
    bottom: #{config.position.bottom};
    font-family: #{config.appearance.fontFamily};
    font-size: #{config.appearance.fontSize}px;
    color: rgb(#{config.appearance.colors.text});
  ">
    <div class="container" style="
      background: rgba(#{config.appearance.colors.background}, #{config.appearance.backgroundOpacity});
      backdrop-filter: blur(#{config.appearance.backgroundBlur}px);
      -webkit-backdrop-filter: blur(#{config.appearance.backgroundBlur}px);
      border-radius: #{config.appearance.borderRadius}px;
      padding: #{config.appearance.padding}px;
      box-shadow: #{config.appearance.boxShadow};
    ">
      <div class="main-content">
        #{logoColumn}
        <div class="column column-2">
          <div class="system-info" id="systemInfo"></div>
          <div class="storage-info" id="storageInfo"></div>
          <div class="summary-info" id="summaryInfo"></div>
        </div>
        <div class="column column-3">
          <div class="network-info" id="networkInfo"></div>
          <div class="cpu-info" id="cpuInfo"></div>
        </div>
        <div class="column column-4">
          <div class="dev-info" id="devInfo"></div>
        </div>
      </div>
      #{debugFooter}
    </div>
  </div>
  """

# ------------------------------------------------------------------------------
# Update Method - Called when new data is available
# ------------------------------------------------------------------------------
update: (output, domEl) ->
  # Track render start time only if debug footer is enabled
  renderStartTime = if config.display.showDebugFooter then Date.now() else null

  # Guard against undefined or empty output
  if not output or output == "undefined"
    return

  try
    data = JSON.parse(output)
  catch error
    console.error "Error parsing JSON:", error
    return

  # Use querySelector from domEl
  $ = (selector) -> domEl.querySelector(selector)

  # Load modules from lib directory (Übersicht ignores /lib per documentation)
  helpers = require('./lib/ui-modules/helpers.coffee')
  logoRenderer = require('./lib/ui-modules/logo-renderer.coffee')(config, helpers)
  systemRenderer = require('./lib/ui-modules/system-renderer.coffee')(config, helpers)
  networkRenderer = require('./lib/ui-modules/network-renderer.coffee')(config, helpers)
  storageRenderer = require('./lib/ui-modules/storage-renderer.coffee')(config, helpers)
  cpuRenderer = require('./lib/ui-modules/cpu-renderer.coffee')(config, helpers)
  devRenderer = require('./lib/ui-modules/dev-renderer.coffee')(config, helpers)

  # Render all sections
  logoRenderer.render(data, $)
  systemRenderer.render(data, $)
  storageRenderer.render(data, $)
  networkRenderer.render(data, $)
  cpuRenderer.render(data, $)
  devRenderer.render(data, $)

  # Update debug footer timing if enabled
  if config.display.showDebugFooter and renderStartTime
    renderTime = Date.now() - renderStartTime

    # Get script execution time if available
    if data.execution_time
      scriptTime = Math.round(data.execution_time)
      totalTime = scriptTime + renderTime
      $('#generation-time')?.innerHTML = "#{totalTime}ms"
    else
      $('#generation-time')?.innerHTML = "#{renderTime}ms"

  return

# ==============================================================================
# WIDGET STYLES (CSS)
# ==============================================================================
style: """
  .widget-wrapper
    margin: 0
    padding: 0

  .container
    display: inline-block

  .main-content
    display: flex
    flex-direction: row
    gap: #{config.layout.columnGap}px
    align-items: flex-start

  .column
    display: flex
    flex-direction: column
    gap: #{config.layout.infoGroupGap}px
    vertical-align: top

  .column-1
    flex: 0 0 auto
    min-width: #{config.layout.column1Width}px

  .column-2
    flex: 1 1 auto
    min-width: #{config.layout.column2Width}px

  .column-3
    flex: 1 1 auto
    min-width: #{config.layout.column3Width}px

  .column-4
    flex: 0 0 auto
    min-width: #{config.layout.column4Width}px

  .logo-section
    flex-shrink: 0
    line-height: #{config.layout.logoLineHeight}
    font-size: #{config.layout.logoFontSize}px
    text-align: center
    align-items: center

  .info-section
    flex-grow: 1
    display: flex
    flex-direction: column
    gap: #{config.layout.infoSectionGap}px

  .info-group
    display: flex
    flex-direction: column
    gap: #{config.layout.infoGroupLineGap}px

  .info-line
    display: flex
    align-items: center
    line-height: #{config.layout.infoLineHeight}

  .label
    display: inline-block
    min-width: #{config.layout.labelMinWidth}px
    margin-right: #{config.layout.labelMarginRight}px
    color: rgba(255, 255, 255, #{config.layout.labelOpacity})
    white-space: nowrap

  .value
    flex: 1
    color: rgb(#{config.appearance.colors.text})

  .separator
    color: rgba(255, 255, 255, #{config.layout.separatorOpacity})
    margin: 0
    padding: 0 5px 0 5px

  .section-header
    font-weight: bold
    color: rgb(#{config.appearance.colors.accent})
    margin-bottom: #{config.layout.sectionHeaderMargin}px

  .debug-footer
    margin-top: 2px
    padding-top: 2px
    position: relative
    text-align: center
    font-size: 10px
    color: rgba(255, 255, 255, 0.75)
    display: flex
    justify-content: center
    gap: 0px

  .debug-footer::before
    content: ''
    position: absolute
    top: 0
    left: 50%
    transform: translateX(-50%)
    width: 60px
    height: 1px
    background: rgba(255, 255, 255, 0.08)

  .debug-footer span
    display: inline-block

  .debug-footer .separator
    opacity: 0.2
"""

# ==============================================================================
# Widget Name Export (fixes display name in Übersicht)
# ==============================================================================
name: "SystemInfoWidget"

# ==============================================================================
# END OF WIDGET
# ==============================================================================
