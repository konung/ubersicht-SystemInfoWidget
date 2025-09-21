# System Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showSystemInfo

    sys = data.system
    hw = data.hardware
    username = if config.display.privacyMode then "user" else sys.username

    uptimeStr = "#{sys.uptime_days}d #{sys.uptime_hours}h #{sys.uptime_minutes}m"
    currentDateTime = sys.current_datetime or ""

    memUsedGB = parseFloat(hw.memory_used)
    memTotalGB = parseFloat(hw.memory_total)

    systemContent = """
      <div class="info-line">
        <span class="label" style='min-width: #{config.layout.defaultLabelWidth}px; display: inline-block; text-align: #{config.layout.defaultLabelTextAlign};'>
          #{helpers.colorize("Hardware", 'accent', config)}
        </span>
        <span class="value">#{sys.os}</span>
      </div>
      <div style="margin-bottom: #{config.layout.separatorMargin}px;"></div>
    """

    systemContent += helpers.infoLine(config.icons.kernel, "Kernel", "#{sys.kernel} | #{sys.host}", config, config.layout.hardwareLabelWidth)

    # Calculate last reboot time
    days = parseInt(sys.uptime_days) || 0
    hours = parseInt(sys.uptime_hours) || 0
    minutes = parseInt(sys.uptime_minutes) || 0
    totalMinutes = days * 24 * 60 + hours * 60 + minutes
    now = new Date()
    rebootTime = new Date(now - totalMinutes * 60000)
    rebootStr = rebootTime.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) + ' ' +
                rebootTime.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false })

    systemContent += helpers.infoLine(config.icons.uptime, "Uptime", "#{uptimeStr} (since #{rebootStr})", config, config.layout.hardwareLabelWidth)

    # Add timezone to time display
    timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
    timeZoneAbbr = new Date().toLocaleTimeString('en-US', {timeZoneName: 'short'}).split(' ').pop()
    systemContent += helpers.infoLine(config.icons.time, "Time", "#{currentDateTime} #{timeZoneAbbr}", config, config.layout.hardwareLabelWidth)

    # Display shell with version if available
    shellInfo = sys.shell
    if sys.shell_version and sys.shell_version != "unknown"
      shellInfo = "#{sys.shell} #{sys.shell_version}"
    systemContent += helpers.infoLine(config.icons.shell, "Shell", shellInfo, config, config.layout.hardwareLabelWidth)

    # Display resolution with display count if more than 1
    resolutionInfo = hw.resolution
    if hw.display_count and parseInt(hw.display_count) > 1
      resolutionInfo = "#{hw.resolution} (#{hw.display_count} displays)"
    systemContent += helpers.infoLine(config.icons.resolution, "Resolution", resolutionInfo, config, config.layout.hardwareLabelWidth)
    if sys.wm_theme
      systemContent += helpers.infoLine(config.icons.theme, "Appearance", sys.wm_theme.replace('Blue ', ''), config, config.layout.hardwareLabelWidth)


    # Memory with pressure if available
    memoryInfo = "#{memUsedGB.toFixed(1)} GB / #{memTotalGB.toFixed(0)} GB"
    if hw.memory_pressure and hw.memory_pressure != "N/A"
      pressureVal = parseInt(hw.memory_pressure)
      pressureColor = if pressureVal > 80 then 'danger' else if pressureVal > 60 then 'warning' else 'success'
      memoryInfo += " (#{helpers.colorize(hw.memory_pressure + '% pressure', pressureColor, config)})"
    systemContent += helpers.infoLine(config.icons.memory, "Memory", memoryInfo, config, config.layout.hardwareLabelWidth)

    systemContent += helpers.infoLine(config.icons.gpu, "GPU", hw.gpu, config, config.layout.hardwareLabelWidth)

    # Audio device if available
    if hw.audio_device
      systemContent += helpers.infoLine(config.icons.audio, "Audio", hw.audio_device, config, config.layout.hardwareLabelWidth)

    # Add swap usage only if actually being used
    if hw.swap_used? and parseFloat(hw.swap_used) > 0
      swapUsedGB = parseFloat(hw.swap_used)
      swapColor = if swapUsedGB > 10 then 'danger' else if swapUsedGB > 5 then 'warning' else 'success'
      swapText = "#{swapUsedGB.toFixed(1)} GB used"
      systemContent += helpers.infoLine(config.icons.memory, "Swap", helpers.colorize(swapText, swapColor, config), config, config.layout.hardwareLabelWidth)

    # Add battery info
    if config.display.showBattery and data.battery and data.battery.percentage
      battery = data.battery
      batteryPercentage = parseInt(battery.percentage)

      if battery.charging == "Yes" or battery.charging == "Charged"
        batteryIcon = config.icons.battery
        batteryColor = 'success'
      else if batteryPercentage < config.thresholds.batteryLow
        batteryIcon = config.icons.batteryLow
        batteryColor = 'danger'
      else
        batteryIcon = config.icons.battery
        batteryColor = if batteryPercentage < config.thresholds.batteryWarning then 'warning' else 'text'

      chargingStatus = if battery.charging == "Yes" then " ⚡" else if battery.charging == "Charged" then " ✓" else ""

      systemContent += helpers.infoLine(batteryIcon, "Battery", "#{helpers.createBar(batteryPercentage, config, batteryColor)} #{battery.percentage}%#{chargingStatus}", config, config.layout.batteryLabelWidth)

      # Add battery health if available
      if battery.cycles and battery.cycles != "N/A"
        cycleColor = if parseInt(battery.cycles) > 1000 then 'danger' else if parseInt(battery.cycles) > 500 then 'warning' else 'text'
        conditionColor = if battery.condition == "Normal" then 'success' else 'warning'
        capacityColor = if parseInt(battery.max_capacity) < 80 then 'danger' else if parseInt(battery.max_capacity) < 90 then 'warning' else 'text'
        healthDetails = "#{helpers.colorize(battery.cycles + ' cycles', cycleColor, config)}, #{helpers.colorize(battery.condition, conditionColor, config)}, #{helpers.colorize(battery.max_capacity + '% capacity', capacityColor, config)}"
        systemContent += helpers.infoLine(batteryIcon, "Health", healthDetails, config, config.layout.batteryLabelWidth)

    # Add Time Machine backup info
    if data.backup and data.backup.time_machine_running
      if data.backup.time_machine_running == "Yes"
        destination = if data.backup.destination and data.backup.destination != "N/A" then " to #{data.backup.destination}" else ""
        tmStatus = "Backing up (#{data.backup.time_machine_percent}%)#{destination}"
        tmColor = 'warning'
      else if data.backup.last_backup and data.backup.last_backup != "N/A"
        tmStatus = "Last: #{data.backup.last_backup}"
        tmColor = 'text'
      else
        tmStatus = "No recent backups"
        tmColor = 'danger'

      systemContent += helpers.infoLine(config.icons.backup, "Backup", helpers.colorize(tmStatus, tmColor, config), config, config.layout.systemLabelWidth)

    $('#systemInfo')?.innerHTML = helpers.infoGroup(systemContent)