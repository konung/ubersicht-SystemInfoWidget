# SystemInfoWidget - Combined system information display
# Merges the best of NetFullSysInfo and ubersicht-neofetch

# Configuration - Customize appearance and behavior
config =
  # Update frequency in milliseconds
  refreshFrequency: 5000
  # Widget position on screen (EDIT THESE VALUES)
  position:
    top: 20  # Change this to move widget vertically
    left: 20   # Change this to move widget horizontally
    right: 'auto'
    bottom: 'auto'
  # Visual settings
  appearance:
    backgroundOpacity: 0.85
    backgroundBlur: 10
    borderRadius: 13
    padding: 20
    fontSize: 15
    iconFontSize: 18  # Font size for Nerd Font icons
    # fontFamily: 'IosevkaTerm Nerd Font Mono,monospace'
    fontFamily: 'IosevkaTerm Nerd Font Mono,monospace'
    boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37)'
    colors:
      background: '20, 20, 20'
      text: '255, 255, 255'
      accent: '106, 196, 255'
      success: '152, 195, 121'
      warning: '229, 192, 123'
      danger: '224, 108, 117'
      muted: '150, 150, 150'
  # Layout settings
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
    sectionHeaderMargin: 8 # Margin below section headers
    separatorMargin: 10    # Margin around separators
    separatorOpacity: 0.3  # Opacity for separator lines
    separatorMinLength: 50 # Minimum length for separator calculation
    infoSectionGap: 12     # Gap inside info sections
    infoGroupLineGap: 4    # Gap between lines in info groups
    infoLineHeight: 1.4    # Line height for info lines
  # Thresholds for color changes
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
  # Display settings
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
    networkAppsCount: 3    # Number of top traffic apps to show (1-5)
    # Apps to skip in network monitoring (common system processes)
    skipNetworkApps: [
      'kernel_task'
      'IPNExtension'
      'mDNSResponder'
      'trustd'
      'nsurlsessiond'
    ]
    privacyMode: false
    compactMode: false
  # Languages to display (comment out ones you don't want)
  languages: [
    'ruby'
    'nodejs'
    'python'
    'crystal'
    'elixir'
    # Add more as needed: 'rust', 'go', 'java', 'php', etc.
  ]
  # Icons (Unicode characters and emojis)
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
    csharp: ''       #     dart: ''         # 🎯 Dart (Nerd Font)
    lua: ''          # 🌙 Lua (Nerd Font)
    perl: ''         # 🐪 Perl (Nerd Font)
    haskell: ''      # λ Haskell (Nerd Font)
    scala: ''        # 🔴 Scala (Nerd Font)
    clojure: ''      # 🍀 Clojure (Nerd Font)
    cpu: ''          # 🧠 CPU (Nerd Font)
    gpu: 'ﮫ'          # 🎮 GPU (Nerd Font)
    memory: ''       # 🧩 Memory (Nerd Font)
    disk: ''         # 💾 Disk (Nerd Font)
    ethernet: ''     # 🔌 Ethernet (Nerd Font)
    wifi: ''         # 📶 Wi-Fi (Nerd Font)
    wifiOff: '睊'     # 📵 Wi-Fi off (Nerd Font)
    localIp: ''      # 🏠 Local IP (Nerd Font - home)
    docker: ''       # 🐳 Docker (Nerd Font)
    bridge: ''       # 🌉 Bridge network (Nerd Font)
    vm: ''           # 📦 Virtual Machine (Nerd Font)
    parallels: ''    # 🔷 Parallels (Nerd Font)
    virtualbox: ''   # 📦 VirtualBox (Nerd Font)
    tailscale: ''    # 🔐 Tailscale (Nerd Font)
    vpn: ''          # 🔒 VPN (Nerd Font)
    hotspot: ''      # 📡 Hotspot (Nerd Font)
    airdrop: ''      # 📤 AirDrop (Nerd Font - share)
    publicIp: ''     # 🌐 Public IP (Nerd Font)
    location: ''     # 📍 Location (Nerd Font)
    isp: ''          # 🏢 ISP/Organization (Nerd Font)
    ping: ''         # 📡 Ping (Nerd Font)
    traffic: ''      # 📊 Network traffic (Nerd Font)
    battery: ''      # 🔋 Battery (Nerd Font)
    batteryCharging: '' # ⚡ Battery charging (Nerd Font)
    batteryLow: ''   # 🪫 Battery low (Nerd Font)
    resolution: ''   # 🖥️ Display resolution (Nerd Font - desktop)
    desktop: ''      # 🖼️ Desktop Environment (Nerd Font - window maximize)
    wm: ''           # 🪟 Window Manager (Nerd Font - window restore)
    theme: ''        # 🎨 Theme (Nerd Font - palette)
    user: ''         # 👤 User (Nerd Font - user circle)
    default: ''      # 🔌 Default/Unknown (Nerd Font - network wired)
  # Progress bar characters
  progressBar:
    filled: '■'       # Filled portion of progress bar (solid square)
    empty: '□'        # Empty portion of progress bar (empty square)
    width: 20         # Total width of progress bar in characters
  # ASCII art logo
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

command: "NETWORK_APPS_COUNT=#{config.display.networkAppsCount} SKIP_NETWORK_APPS='#{config.display.skipNetworkApps.join(',')}' SystemInfoWidget.widget/system-info.sh"

refreshFrequency: config.refreshFrequency

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
          <div class="summary-info" id="summaryInfo"></div>
        </div>
        <div class="column column-3">
          <div class="storage-info" id="storageInfo"></div>
          <div class="network-info" id="networkInfo"></div>
        </div>
        <div class="column column-4">
          <div class="dev-info" id="devInfo"></div>
        </div>
      </div>
    </div>
  </div>
  """

update: (output, domEl) ->
  try
    data = JSON.parse(output)
  catch error
    console.error "Error parsing JSON:", error
    return

  cfg = config

  # Helper function to create colored text
  colorize = (text, type = 'accent') ->
    colors = cfg.appearance.colors
    colorMap = {
      'accent': colors.accent
      'success': colors.success
      'warning': colors.warning
      'danger': colors.danger
      'text': colors.text
      'muted': colors.muted
    }
    color = colorMap[type] or colors.text
    "<span style='color: rgb(#{color})'>#{text}</span>"

  # Helper function for section headers
  sectionHeader = (title) ->
    """<div class="info-line">
      <span class="section-header">#{title}</span>
    </div>"""

  # Helper function for info lines
  infoLine = (icon, label, value, labelWidth = null, textAlign = null) ->
    # Use provided values or fall back to defaults from config
    width = labelWidth ? cfg.layout.defaultLabelWidth
    align = textAlign ? cfg.layout.defaultLabelTextAlign

    widthStyle = "style='min-width: #{width}px; display: inline-block; text-align: #{align};'"
    # Add icon with separate font size if present
    labelText = if icon
      "<span style='font-size: #{cfg.appearance.iconFontSize}px; margin-right: 4px;'>#{icon}</span>#{label}"
    else
      label
    """<div class="info-line">
      <span class="label" #{widthStyle}>#{labelText}:</span>
      <span class="value">#{value}</span>
    </div>"""

  # Helper function to start an info group
  infoGroup = (content) ->
    """<div class="info-group">#{content}</div>"""

  # Render logo if enabled
  if cfg.display.showLogo
    logoHtml = cfg.logo.map((line) ->
      "<div>#{colorize(line, 'accent')}</div>"
    ).join('')
    $('#logo').html(logoHtml)

  # System Information - Merged with icons
  if cfg.display.showSystemInfo
    sys = data.system
    hw = data.hardware
    username = if cfg.display.privacyMode then "user" else sys.username
    full_hostname = if cfg.display.privacyMode then "hostname" else sys.full_hostname

    uptimeStr = "#{sys.uptime_days} days, #{sys.uptime_hours} hours, #{sys.uptime_minutes} mins"

    # Create separator line based on hostname length
    separatorLength = Math.max(cfg.layout.separatorMinLength, "#{username}@#{full_hostname}".length)

    # Parse CPU usage
    cpuUsage = parseFloat(hw.cpu_usage)
    cpuColor = if cpuUsage > cfg.thresholds.cpuDanger then 'danger' else if cpuUsage > cfg.thresholds.cpuWarning then 'warning' else 'success'

    # Memory in GB
    memUsedGB = parseFloat(hw.memory_used)
    memTotalGB = parseFloat(hw.memory_total)

    systemContent = """
      <div class="info-line">
        #{colorize("#{username}@#{sys.hostname}", 'accent')}
      </div>
      <div style="margin-bottom: #{cfg.layout.separatorMargin}px;"></div>
      #{infoLine(cfg.icons.os, "OS", sys.os)}
      #{infoLine(cfg.icons.host, "Host", sys.host)}
      #{infoLine(cfg.icons.kernel, "Kernel", sys.kernel)}
      #{infoLine(cfg.icons.uptime, "Uptime", uptimeStr)}
      #{(() ->
        # Show both Intel (x86) and ARM brew stats
        intelCount = parseInt(sys.packages_brew_intel || 0)
        armCount = parseInt(sys.packages_brew_arm || 0)
        totalCount = intelCount + armCount

        intelOutdated = parseInt(sys.packages_outdated_intel || 0)
        armOutdated = parseInt(sys.packages_outdated_arm || 0)

        # Format the display
        brewInfo = "#{totalCount} total"

        # Show breakdown if both exist
        if intelCount > 0 and armCount > 0
          brewInfo = "#{intelCount} x86"
          if intelOutdated > 0
            outdatedColor = if intelOutdated > 50 then 'danger' else if intelOutdated > 10 then 'warning' else 'success'
            brewInfo += " (#{colorize(intelOutdated + '↑', outdatedColor)})"

          brewInfo += ", #{armCount} arm"
          if armOutdated > 0
            outdatedColor = if armOutdated > 50 then 'danger' else if armOutdated > 10 then 'warning' else 'success'
            brewInfo += " (#{colorize(armOutdated + '↑', outdatedColor)})"
        else if intelCount > 0
          # Only Intel
          brewInfo = "#{intelCount} (x86)"
          if intelOutdated > 0
            outdatedColor = if intelOutdated > 50 then 'danger' else if intelOutdated > 10 then 'warning' else 'success'
            brewInfo += " • #{colorize(intelOutdated + ' need update', outdatedColor)}"
        else if armCount > 0
          # Only ARM
          brewInfo = "#{armCount} (arm)"
          if armOutdated > 0
            outdatedColor = if armOutdated > 50 then 'danger' else if armOutdated > 10 then 'warning' else 'success'
            brewInfo += " • #{colorize(armOutdated + ' need update', outdatedColor)}"

        infoLine(cfg.icons.brew, "Brew", brewInfo)
      )()}
      #{infoLine(cfg.icons.shell, "Shell", sys.shell)}
      #{infoLine(cfg.icons.resolution, "Resolution", hw.resolution)}
      #{infoLine(cfg.icons.theme, "Appearance", sys.wm_theme.replace('Blue ', ''))}
      #{infoLine(cfg.icons.terminal, "Terminal", sys.terminal)}
      #{infoLine(cfg.icons.cpu, "CPU", "#{hw.cpu} [#{hw.cpu_threads}] (#{colorize(hw.cpu_usage + '%', cpuColor)})")}
      #{infoLine(cfg.icons.gpu, "GPU", hw.gpu)}
      #{infoLine(cfg.icons.memory, "Memory", "#{memUsedGB.toFixed(1)} GB / #{memTotalGB.toFixed(0)} GB")}
    """

    # Add battery info to system section if available
    if cfg.display.showBattery and data.battery.percentage
      battery = data.battery
      batteryPercentage = parseInt(battery.percentage)

      # Determine battery icon and color
      if battery.charging == "Yes" or battery.charging == "Charged"
        batteryIcon = cfg.icons.battery
        batteryColor = 'success'
      else if batteryPercentage < cfg.thresholds.batteryLow
        batteryIcon = cfg.icons.batteryLow
        batteryColor = 'danger'
      else
        batteryIcon = cfg.icons.battery
        batteryColor = if batteryPercentage < cfg.thresholds.batteryWarning then 'warning' else 'text'

      createBar = (percentage, color) ->
        filled = Math.round(percentage * cfg.progressBar.width / 100)
        empty = cfg.progressBar.width - filled
        bar = cfg.progressBar.filled.repeat(filled) + cfg.progressBar.empty.repeat(empty)
        colorize(bar, color)

      chargingStatus = if battery.charging == "Yes" then " ⚡" else if battery.charging == "Charged" then " ✓" else ""

      systemContent += infoLine(batteryIcon, "Battery", "#{createBar(batteryPercentage, batteryColor)} #{battery.percentage}%#{chargingStatus}")

    systemHtml = infoGroup(systemContent)
    $('#systemInfo').html(systemHtml)

  # Hardware section removed - merged into system info

  # Storage Information
  if cfg.display.showStorage
    storage = data.storage
    diskPercentage = parseInt(storage.disk_percentage)
    diskColor = if diskPercentage > cfg.thresholds.diskDanger then 'danger' else if diskPercentage > cfg.thresholds.diskWarning then 'warning' else 'success'

    # Use the percentage from the script (now accurate from APFS)
    actualPercentage = storage.disk_percentage

    createBar = (percentage, color) ->
      filled = Math.round(percentage * cfg.progressBar.width / 100)
      empty = cfg.progressBar.width - filled
      bar = cfg.progressBar.filled.repeat(filled) + cfg.progressBar.empty.repeat(empty)
      colorize(bar, color)

    storageContent = """
      #{sectionHeader("Storage")}
      #{infoLine(cfg.icons.disk, "Disk", "#{storage.disk_used} / #{storage.disk_total} (#{storage.disk_available} free)")}
      #{infoLine(cfg.icons.disk, "Usage", "#{createBar(diskPercentage, diskColor)} #{actualPercentage}% used")}
    """
    storageHtml = infoGroup(storageContent)
    $('#storageInfo').html(storageHtml)

  # Network Information - All interfaces
  if cfg.display.showNetwork
    net = data.network
    sys = data.system

    networkContent = sectionHeader("Network Info")

    # Add hostname and FQDN
    networkContent += infoLine(cfg.icons.host, "Hostname", sys.hostname, cfg.layout.networkLabelWidth)
    networkContent += infoLine(cfg.icons.host, "FQDN", sys.full_hostname, cfg.layout.networkLabelWidth)

    # Display ALL network interfaces from the array
    if net.interfaces and net.interfaces.length > 0
      for iface in net.interfaces
        # Choose icon based on interface type
        icon = switch iface.type
          when 'wifi' then cfg.icons.wifi
          when 'ethernet' then cfg.icons.ethernet
          when 'tailscale' then cfg.icons.tailscale
          when 'vpn' then cfg.icons.vpn
          when 'docker' then cfg.icons.docker
          when 'bridge' then cfg.icons.bridge
          when 'vm' then cfg.icons.vm
          when 'parallels' then cfg.icons.parallels
          when 'virtualbox' then cfg.icons.virtualbox
          when 'hotspot' then cfg.icons.hotspot
          when 'airdrop' then cfg.icons.airdrop
          else cfg.icons.default

        # Add SSID for Wi-Fi if available
        displayName = iface.name
        if iface.type == 'wifi' and net.wifi_ssid and net.wifi_ssid != ''
          displayName = "Wi-Fi (#{net.wifi_ssid})"

        networkContent += infoLine(icon, displayName, iface.ip, cfg.layout.networkLabelWidth)

    # Public IP and location info
    networkContent += infoLine(cfg.icons.publicIp, "Public IP", net.public_ip, cfg.layout.networkLabelWidth)

    # Public hostname if available
    if net.public_hostname and net.public_hostname != ""
      networkContent += infoLine(cfg.icons.publicIp, "Public FQDN", net.public_hostname, cfg.layout.networkLabelWidth)

    # Location if available
    if net.public_location and net.public_location != ""
      networkContent += infoLine(cfg.icons.location, "Location", net.public_location, cfg.layout.networkLabelWidth)

    # ISP/Organization if available
    if net.public_org and net.public_org != ""
      networkContent += infoLine(cfg.icons.isp, "ISP", net.public_org, cfg.layout.networkLabelWidth)

    # Ping
    if net.ping and net.ping != 'N/A'
      pingValue = parseFloat(net.ping)
      pingColor = if pingValue > cfg.thresholds.pingWarning then 'danger' else if pingValue > cfg.thresholds.pingGood then 'warning' else 'success'
      pingTarget = net.ping_target or '8.8.8.8'
      networkContent += infoLine(cfg.icons.ping, "Ping (#{pingTarget})", colorize(net.ping + ' ms', pingColor), cfg.layout.networkLabelWidth)

    # Network traffic
    if net.traffic_down and net.traffic_up
      trafficInfo = "↓ #{colorize(net.traffic_down, 'success')} ↑ #{colorize(net.traffic_up, 'warning')}"
      networkContent += infoLine(cfg.icons.traffic, "Traffic", trafficInfo, cfg.layout.networkLabelWidth)

    # Top apps using network
    if cfg.display.showNetworkApps and net.apps and net.apps.length > 0
      networkContent += """<div style="margin-top: 8px;">"""
      for app, index in net.apps
        # Show app name with traffic info
        appTraffic = "↓ #{colorize(app.down, 'success')} ↑ #{colorize(app.up, 'warning')}"
        appLabel = "  #{index + 1}. #{app.name}"
        networkContent += infoLine('', appLabel, appTraffic, cfg.layout.networkLabelWidth)
      networkContent += """</div>"""

    networkHtml = infoGroup(networkContent)

    $('#networkInfo').html(networkHtml)

  # Dev/Software Information
  if cfg.display.showDev
    sys = data.system

    devContent = sectionHeader("Dev/Software")

    # Show language versions if enabled
    if cfg.display.showLanguages and sys.version_manager
      # Build string of configured languages and their versions
        # Show version manager at the bottom
      if sys.version_manager != "none"
        devContent += infoLine(cfg.icons.languages, "Manager", sys.version_manager)

      for lang in cfg.languages
        langKey = "lang_#{lang}"
        # Handle nodejs special case
        langKey = "lang_nodejs" if lang == "nodejs" or lang == "node"

        version = sys[langKey]
        if version and version != "N/A"
          # Shorten version display
          shortVersion = version.split('-')[0]  # Remove pre-release/build info
          # Get language-specific icon or use default
          langIcon = if lang == "node"
            cfg.icons["nodejs"] or "📦"
          else
            cfg.icons[lang] or "📦"
          # Capitalize language name for display
          displayName = lang.charAt(0).toUpperCase() + lang.slice(1)
          devContent += infoLine(langIcon, displayName, shortVersion)



    devHtml = infoGroup(devContent)
    $('#devInfo').html(devHtml)

  # Battery Information now integrated into systemInfo section above

  # Summary Info Section (NetFullSysInfo style)
  if cfg.display.showSystemInfo
    sys = data.system
    hw = data.hardware
    storage = data.storage
    net = data.network
    battery = data.battery

    # Memory calculation
    memUsedGB = parseFloat(hw.memory_used)
    memTotalGB = parseFloat(hw.memory_total)

    # Uptime
    uptimeStr = "#{sys.uptime_days}d #{sys.uptime_hours}h #{sys.uptime_minutes}m"

    # Disk format to match Ti notation
    diskUsed = storage.disk_used
    diskTotal = storage.disk_total.replace('G', 'GB')
    if diskTotal.includes('T')
      diskTotal = diskTotal.replace('TB', 'Ti')

    # Battery icon
    batteryPercentage = parseInt(battery.percentage)
    batteryWarning = if batteryPercentage < 20 then "⚠️ " else ""
    batteryInfo = "#{batteryWarning}#{battery.percentage}%"
    if battery.charging == "Yes"
      batteryInfo += " #{cfg.icons.batteryCharging}"

    # Ping with target
    pingInfo = if net.ping and net.ping != 'N/A'
      pingTarget = net.ping_target or '8.8.8.8'
      "#{net.ping} ms to #{pingTarget}"
    else
      "N/A"



style: """
  .widget-wrapper
    margin: 0
    padding: 0

  .main-content
    display: flex
    gap: #{config.layout.columnGap}px
    align-items: flex-start

  .column
    display: flex
    flex-direction: column
    gap: #{config.layout.infoGroupGap}px

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
    margin: 4px 0

  .section-header
    font-weight: bold
    color: rgb(#{config.appearance.colors.accent})
    margin-bottom: #{config.layout.sectionHeaderMargin}px
"""
