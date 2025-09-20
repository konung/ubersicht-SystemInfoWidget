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
        #{helpers.colorize("#{username}@#{sys.hostname}", 'accent', config)}
      </div>
      <div style="margin-bottom: #{config.layout.separatorMargin}px;"></div>
    """

    systemContent += helpers.infoLine(config.icons.os, "OS", sys.os, config)
    systemContent += helpers.infoLine(config.icons.host, "Host", sys.host, config)
    systemContent += helpers.infoLine(config.icons.kernel, "Kernel", sys.kernel, config)
    systemContent += helpers.infoLine(config.icons.uptime, "Uptime", "#{uptimeStr} | #{currentDateTime}", config)

    # Add Brew info after uptime
    if data.packages
      packages = data.packages
      intelCount = parseInt(packages.brew_intel || 0)
      armCount = parseInt(packages.brew_arm || 0)
      totalCount = intelCount + armCount

      intelOutdated = parseInt(packages.outdated_intel || 0)
      armOutdated = parseInt(packages.outdated_arm || 0)

      brewInfo = "#{totalCount} total"

      if intelCount > 0 and armCount > 0
        brewInfo = "#{intelCount} x86"
        if intelOutdated > 0
          outdatedColor = if intelOutdated > 50 then 'danger' else if intelOutdated > 10 then 'warning' else 'success'
          brewInfo += " (#{helpers.colorize(intelOutdated + '↑', outdatedColor, config)})"

        brewInfo += ", #{armCount} arm"
        if armOutdated > 0
          outdatedColor = if armOutdated > 50 then 'danger' else if armOutdated > 10 then 'warning' else 'success'
          brewInfo += " (#{helpers.colorize(armOutdated + '↑', outdatedColor, config)})"
      else if intelCount > 0
        brewInfo = "#{intelCount} (x86)"
        if intelOutdated > 0
          outdatedColor = if intelOutdated > 50 then 'danger' else if intelOutdated > 10 then 'warning' else 'success'
          brewInfo += " • #{helpers.colorize(intelOutdated + ' need update', outdatedColor, config)}"
      else if armCount > 0
        brewInfo = "#{armCount} (arm)"
        if armOutdated > 0
          outdatedColor = if armOutdated > 50 then 'danger' else if armOutdated > 10 then 'warning' else 'success'
          brewInfo += " • #{helpers.colorize(armOutdated + ' need update', outdatedColor, config)}"

      systemContent += helpers.infoLine(config.icons.brew, "Brew", brewInfo, config)

    systemContent += helpers.infoLine(config.icons.shell, "Shell", sys.shell, config)
    systemContent += helpers.infoLine(config.icons.resolution, "Resolution", hw.resolution, config)
    if sys.wm_theme
      systemContent += helpers.infoLine(config.icons.theme, "Appearance", sys.wm_theme.replace('Blue ', ''), config)
    systemContent += helpers.infoLine(config.icons.gpu, "GPU", hw.gpu, config)
    systemContent += helpers.infoLine(config.icons.memory, "Memory", "#{memUsedGB.toFixed(1)} GB / #{memTotalGB.toFixed(0)} GB", config)

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

      systemContent += helpers.infoLine(batteryIcon, "Battery", "#{helpers.createBar(batteryPercentage, config, batteryColor)} #{battery.percentage}%#{chargingStatus}", config)

      # Add battery health if available
      if battery.cycles and battery.cycles != "N/A"
        cycleColor = if parseInt(battery.cycles) > 1000 then 'danger' else if parseInt(battery.cycles) > 500 then 'warning' else 'text'
        conditionColor = if battery.condition == "Normal" then 'success' else 'warning'
        capacityColor = if parseInt(battery.max_capacity) < 80 then 'danger' else if parseInt(battery.max_capacity) < 90 then 'warning' else 'text'
        healthDetails = "#{helpers.colorize(battery.cycles + ' cycles', cycleColor, config)}, #{helpers.colorize(battery.condition, conditionColor, config)}, #{helpers.colorize(battery.max_capacity + '% capacity', capacityColor, config)}"
        systemContent += helpers.infoLine(batteryIcon, "Health", healthDetails, config)

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

      systemContent += helpers.infoLine(config.icons.backup, "Backup", helpers.colorize(tmStatus, tmColor, config), config)

    $('#systemInfo')?.innerHTML = helpers.infoGroup(systemContent)