# Storage Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showStorage

    storage = data.storage
    diskPercentage = parseInt(storage.disk_percentage)
    diskColor = if diskPercentage > config.thresholds.diskDanger then 'danger' else if diskPercentage > config.thresholds.diskWarning then 'warning' else 'success'

    storageContent = """
      #{helpers.sectionHeader("Storage")}
      #{helpers.infoLine(config.icons.disk, "Disk", "#{storage.disk_used} / #{storage.disk_total} (#{storage.disk_available} free)", config)}
      #{helpers.infoLine(config.icons.diskUsage, "Usage", "#{helpers.createBar(diskPercentage, config, diskColor)} #{storage.disk_percentage}% used", config)}
    """

    $('#storageInfo')?.innerHTML = helpers.infoGroup(storageContent)