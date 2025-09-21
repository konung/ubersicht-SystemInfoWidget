# ==============================================================================
# SystemInfoWidget - Advanced System Monitor for Übersicht
# ==============================================================================
# Version: 3.7.0
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
  version: '3.7.0'
  refreshFrequency: 5000  # Update interval in milliseconds (2.5 seconds)

  # ----------------------------------------------------------------------------
  # Widget Position
  # ----------------------------------------------------------------------------
  position:
    bottom: 'auto'  # Distance from bottom (use 'auto' to position from top)
    left: 20        # Distance from left of screen (pixels)
    right: 'auto'   # Distance from right (use 'auto' to position from left)
    top: 20         # Distance from top of screen (pixels)

  # ----------------------------------------------------------------------------
  # Visual Appearance
  # ----------------------------------------------------------------------------
  appearance:
    # fontFamily: 'IosevkaTerm Nerd Font Mono,monospace'
    backgroundBlur: 10
    backgroundOpacity: 0.8
    borderRadius: 13
    boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37)'
    fontFamily: 'Iosevka Term SS09,IosevkaTerm Nerd Font Mono,monospace'
    fontSize: 15
    iconFontSize: 20  # Font size for Nerd Font icons
    padding: 20
    # Color scheme (RGB values)
    colors:
      accent: '106, 196, 255'
      background: '20, 20, 20'
      danger: '224, 108, 117'
      muted: '150, 150, 150'
      success: '152, 195, 121'
      text: '255, 255, 255'
      warning: '229, 192, 123'

  # ----------------------------------------------------------------------------
  # Layout Settings
  # ----------------------------------------------------------------------------
  layout:
    column1Width: 200      # First column min width (logo)
    column2Width: 350      # Second column min width
    column3Width: 350      # Third column min width
    column4Width: 200      # Fourth column min width (Dev/Software)
    columnGap: 30           # Gap between columns
    defaultLabelTextAlign: 'justify'  # Default text alignment for labels
    defaultLabelWidth: 100  # Default width for all labels
    infoGroupGap: 15       # Gap between info groups
    infoGroupLineGap: 1    # Gap between lines in info groups
    infoLineHeight: 1.1    # Line height for info lines
    infoSectionGap: 8      # Gap inside info sections
    labelMarginRight: 10   # Space after labels
    labelMinWidth: 150     # Default label min width (deprecated, use defaultLabelWidth)
    labelOpacity: 0.7      # Opacity for labels
    logoFontSize: 20       # Logo font size
    logoLineHeight: 1.2    # Line height for logo text
    networkLabelWidth: 150  # Width for network interface labels
    trafficLabelWidth: 150  # Width for traffic section labels
    systemLabelWidth: 100   # Width for system info labels
    hardwareLabelWidth: 100 # Width for hardware info labels
    storageLabelWidth: 100  # Width for storage info labels
    batteryLabelWidth: 100  # Width for battery info labels
    cpuLabelWidth: 100      # Width for CPU info labels
    devLabelWidth: 100      # Width for dev/software labels
    sectionHeaderMargin: 0  # Margin below section headers
    separatorMargin: 10    # Margin around separators
    separatorMinLength: 50 # Minimum length for separator calculation
    separatorOpacity: 0.9  # Opacity for separator lines

  # ----------------------------------------------------------------------------
  # Performance Thresholds (for color coding)
  # ----------------------------------------------------------------------------
  thresholds:
    batteryLow: 20
    batteryWarning: 40
    cpuDanger: 80
    cpuWarning: 300
    diskDanger: 80
    diskWarning: 60
    memoryDanger: 80
    memoryWarning: 60
    pingGood: 50
    pingWarning: 100

  # ----------------------------------------------------------------------------
  # Display Settings - Toggle sections on/off
  # ----------------------------------------------------------------------------
  display:

    # Apps to skip in network monitoring (common system processes)
    compactMode: false     # Use compact layout (not implemented)
    networkAppsCount: 3    # Number of top traffic apps to show (1-5)
    privacyMode: false     # Hide sensitive information
    showBattery: true
    showDebugFooter: false # Show debug footer with timing info (impacts performance)
    showDev: true          # Show Dev/Software section
    showHardware: true
    showLanguages: true    # Show programming language versions
    showLogo: false        # Show/hide ASCII art logo
    showNetwork: true
    showNetworkApps: true  # Show apps using network traffic
    showStorage: true
    showSystemInfo: true
    skipNetworkApps: [
      'IPNExtension'
      'kernel_task'
      'mDNSResponder'
      'nsurlsessiond'
      'trustd'
    ]
  # ----------------------------------------------------------------------------
  # Programming Languages to Display
  # ----------------------------------------------------------------------------
  # Comment out languages you don't want to see
  languages: [
    'bun'
    'crystal'
    'elixir'
    'nim'
    'nodejs'
    'python'
    'ruby'
  ]

  # ----------------------------------------------------------------------------
  # Icons (Nerd Font icons - requires Nerd Font installation)
  # ----------------------------------------------------------------------------
  icons:
    airdrop: ''      # 📤 AirDrop (Nerd Font - share)
    audio: '󰓃'        # Audio device (Nerd Font - speaker)
    backup: '󰁯'       # 🕑 Backup (Nerd Font - time)
    battery: ''      # 🔋 Battery (Nerd Font)
    batteryCharging: '' # ⚡ Battery charging (Nerd Font)
    batteryLow: ''   # 🪫 Battery low (Nerd Font)
    brew: ''         # 🍺 Homebrew (Nerd Font)
    bridge: ''       # 🌉 Bridge network (Nerd Font)
    bun: '󰙯'          # 🍞 Bun (Nerd Font)
    c: ''            # 🔤 C (Nerd Font)
    clojure: ''      # 🍀 Clojure (Nerd Font)
    connections: '󰍛'  # 🔗 Active connections (Nerd Font)
    cpp: ''          # ➕ C++ (Nerd Font)
    cpu: ''          # 🧠 CPU (Nerd Font)
    crystal: ''      # 💎 Crystal (Nerd Font)
    csharp: ''       # 💻 CSharp (Nerd Font)
    dart: ''         # 🎯 Dart (Nerd Font)
    default: ''      # 🔌 Default/Unknown (Nerd Font - network wired)
    desktop: ''      # 🖼️ Desktop Environment (Nerd Font - window maximize)
    disk: '󰋊'         # 💾 Disk (Nerd Font)
    diskIO: '󰓅'       # Disk I/O (Nerd Font - database)
    diskUsage: '󱁌'    # 💾 Disk (Nerd Font)
    docker: ''       # 🐳 Docker (Nerd Font)
    elixir: ''       # 💧 Elixir (Nerd Font)
    ethernet: '󰈀'     # 🔌 Ethernet (Nerd Font)
    go: ''           # 🐹 Go (Nerd Font)
    gpu: 'ﮫ'          # 🎮 GPU (Nerd Font)
    haskell: ''      # λ Haskell (Nerd Font)
    host: ''         # 🖥️ Host machine (Nerd Font)
    hotspot: ''      # 📡 Hotspot (Nerd Font)
    isp: ''          # 🏢 ISP/Organization (Nerd Font)
    java: ''         # ☕ Java (Nerd Font)
    javascript: ''   # 📜 JavaScript (Nerd Font)
    kernel: ''       # 🔧 Kernel (Nerd Font)
    kotlin: ''       # 🅺 Kotlin (Nerd Font)
    languages: ''    # 📝 Programming languages (Nerd Font code)
    localIp: ''      # 🏠 Local IP (Nerd Font - home)
    lua: ''          # 🌙 Lua (Nerd Font)
    memory: ''       # 🧩 Memory (Nerd Font)
    nim: '󰒲'          # 🦕 Nim (Nerd Font)
    nodejs: ''       # 📦 Node.js (Nerd Font)
    os: ''           # 🍎 Apple logo (Nerd Font)
    parallels: ''    # 🔷 Parallels (Nerd Font)
    perl: ''         # 🐪 Perl (Nerd Font)
    php: ''          # 🐘 PHP (Nerd Font)
    ping: '󱦂'         # 📡 Ping (Nerd Font)
    publicIp: ''     # 🌐 Public IP (Nerd Font)
    publicLocation: ''     # 📍 Location (Nerd Font)
    python: ''       # 🐍 Python (Nerd Font)
    resolution: '󰨇'   # Display resolution (Nerd Font - monitor)
    ruby: ''         # 💎 Ruby (Nerd Font)
    rust: ''         # 🦀 Rust (Nerd Font)
    scala: ''        # 🔴 Scala (Nerd Font)
    shell: ''        # 🐚 Shell (Nerd Font)
    swift: ''        # 🦉 Swift (Nerd Font)
    tailscale: '󰖂'    # 🔐 Tailscale (Nerd Font)
    terminal: ''     # 💻 Terminal (Nerd Font)
    theme: '󰔎'        # 🎨 Theme (Nerd Font - palette)
    time: '󰭖'         # 🕐 Current Time (Nerd Font)
    traffic: ''      # 📊 Network traffic (Nerd Font)
    typescript: 'ﯤ'   # 📘 TypeScript (Nerd Font)
    uptime: ''       # ⏱️ Uptime (Nerd Font)
    usb: '󰗮'          # 💾 USB drive (Nerd Font)
    user: ''         # 👤 User (Nerd Font - user circle)
    virtualbox: ''   # 📦 VirtualBox (Nerd Font)
    vm: ''           # 📦 Virtual Machine (Nerd Font)
    vpn: ''          # 🔒 VPN (Nerd Font)
    wifi: ''         # 📶 Wi-Fi (Nerd Font)
    wifiOff: '󱚼'      # 📵 Wi-Fi off (Nerd Font)
    wm: ''           # 🪟 Window Manager (Nerd Font - window restore)

  # ----------------------------------------------------------------------------
  # Progress Bar Settings
  # ----------------------------------------------------------------------------
  progressBar:
    empty: '□'        # Empty portion of progress bar (empty square)
    filled: '■'       # Filled portion of progress bar (solid square)
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
      position: relative;
    ">
      <div class="refresh-button" id="refreshButton" title="Force cache refresh" style="
        position: absolute;
        top: 10px;
        right: 10px;
        cursor: pointer;
        opacity: 0.5;
        transition: opacity 0.2s;
        font-size: 18px;
        z-index: 1000;
        color: rgb(#{config.appearance.colors.text});
      ">
        ↻
      </div>
      <div class="main-content">
        #{logoColumn}
        <div class="column column-2">
          <div class="system-info" id="systemInfo"></div>
          <div class="storage-info" id="storageInfo"></div>
          <div class="summary-info" id="summaryInfo"></div>
        </div>
        <div class="column column-3">
          <div class="network-info" id="networkInfo"></div>
          <div class="traffic-info" id="trafficInfo"></div>
        </div>
        <div class="column column-4">
          <div class="dev-info" id="devInfo"></div>
          <div class="processes-info" id="processesInfo"></div>
        </div>
      </div>
      #{debugFooter}
    </div>
  </div>
  """

# ------------------------------------------------------------------------------
# After Render Method - Called after initial render
# ------------------------------------------------------------------------------
afterRender: (domEl) ->
  # Setup click handler for refresh button
  refreshBtn = domEl.querySelector('#refreshButton')
  if refreshBtn
    refreshBtn.onclick = =>
      # Delete cache file
      @run "rm -f 'SystemInfoWidget.widget/.cache.json'", (error, output) =>
        if error
          console.error "Error deleting cache:", error
        else
          # Animate the refresh icon
          refreshBtn.style.transform = 'rotate(360deg)'
          setTimeout ->
            refreshBtn.style.transform = 'rotate(0deg)'
          , 500
          # Force immediate widget refresh
          @refresh()

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
  trafficRenderer = require('./lib/ui-modules/traffic-renderer.coffee')(config, helpers)
  storageRenderer = require('./lib/ui-modules/storage-renderer.coffee')(config, helpers)
  cpuRenderer = require('./lib/ui-modules/cpu-renderer.coffee')(config, helpers)
  devRenderer = require('./lib/ui-modules/dev-renderer.coffee')(config, helpers)

  # Render all sections
  logoRenderer.render(data, $)
  systemRenderer.render(data, $)
  storageRenderer.render(data, $)
  networkRenderer.render(data, $)
  trafficRenderer.render(data, $)
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

  .refresh-button
    transition: transform 0.5s, opacity 0.2s !important

  .refresh-button:hover
    opacity: 1 !important

  .refresh-button:active
    opacity: 0.8 !important
"""

# ==============================================================================
# Widget Name Export (fixes display name in Übersicht)
# ==============================================================================
name: "SystemInfoWidget"

# ==============================================================================
# END OF WIDGET
# ==============================================================================
