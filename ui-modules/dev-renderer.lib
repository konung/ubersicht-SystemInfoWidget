# Dev/Software Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showDev and data.dev

    dev = data.dev
    packages = data.packages

    devContent = helpers.sectionHeader("Dev/Software")

    # Brew packages
    if packages
      totalBrew = (packages.brew_intel || 0) + (packages.brew_arm || 0) + (packages.brew_intel_cask || 0) + (packages.brew_arm_cask || 0)
      totalOutdated = (packages.outdated_intel || 0) + (packages.outdated_arm || 0)
      if totalBrew > 0
        brewInfo = "#{totalBrew} packages"
        if totalOutdated > 0
          brewInfo += " (#{totalOutdated} outdated)"
        devContent += helpers.infoLine(config.icons.brew, "Brew", brewInfo, config)

    # Language versions
    if config.display.showLanguages and dev.languages
      if dev.version_manager and dev.version_manager != "none"
        devContent += helpers.infoLine(config.icons.languages, "Manager", dev.version_manager, config)

      for lang in config.languages
        version = dev.languages[lang]
        if version and version != "N/A" and version != ""
          shortVersion = version.split('-')[0]
          langIcon = config.icons[lang] || config.icons.package || "📦"
          displayName = lang.charAt(0).toUpperCase() + lang.slice(1)
          devContent += helpers.infoLine(langIcon, displayName, shortVersion, config)

    $('#devInfo')?.innerHTML = helpers.infoGroup(devContent)