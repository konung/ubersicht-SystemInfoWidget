# Dev/Software Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showDev and data.dev

    dev = data.dev
    packages = data.packages

    devContent = helpers.sectionHeader("Dev/Software (mise)")

    # Brew packages with detailed breakdown
    if packages
      intelCount = parseInt(packages.brew_intel || 0)
      armCount = parseInt(packages.brew_arm || 0)
      totalCount = intelCount + armCount

      intelOutdated = parseInt(packages.outdated_intel || 0)
      armOutdated = parseInt(packages.outdated_arm || 0)

      brewInfo = ""

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

      if brewInfo != ""
        devContent += helpers.infoLine(config.icons.brew, "Brew", brewInfo, config, config.layout.devLabelWidth)

    # Docker containers if available
    if dev.docker_total? and dev.docker_total > 0
      dockerInfo = "#{dev.docker_running} running"
      if dev.docker_total > dev.docker_running
        dockerInfo += ", #{dev.docker_total - dev.docker_running} stopped"
      devContent += helpers.infoLine(config.icons.docker, "Containers", dockerInfo, config, config.layout.devLabelWidth)

    # Language versions
    if config.display.showLanguages and dev.languages
      if dev.version_manager and dev.version_manager != "none"
        devContent += helpers.infoLine(config.icons.languages, "Manager", dev.version_manager, config, config.layout.devLabelWidth)

      # Get latest versions if available
      latestVersions = dev.languages.mise_latest || {}

      for lang in config.languages
        version = dev.languages[lang]
        if version and version != "N/A" and version != ""
          shortVersion = version.split('-')[0]
          langIcon = config.icons[lang] || config.icons.package || "📦"
          displayName = lang.charAt(0).toUpperCase() + lang.slice(1)

          # Check if there's a newer version available
          latestVersion = latestVersions[lang]
          if latestVersion and latestVersion != shortVersion
            # Extract major.minor for comparison
            currentParts = shortVersion.split('.')
            latestParts = latestVersion.split('.')

            # Determine if it's a major, minor, or patch update
            updateType = 'patch'
            if currentParts[0] != latestParts[0]
              updateType = 'major'
            else if currentParts[1] != latestParts[1]
              updateType = 'minor'

            # Color based on update type
            updateColor = if updateType == 'major' then 'warning' else 'success'
            versionInfo = "#{shortVersion} (#{helpers.colorize(latestVersion + '↑', updateColor, config)})"
          else
            versionInfo = shortVersion

          devContent += helpers.infoLine(langIcon, displayName, versionInfo, config, config.layout.devLabelWidth)

    $('#devInfo')?.innerHTML = helpers.infoGroup(devContent)
