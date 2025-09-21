# Storage Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showStorage

    storage = data.storage
    diskPercentage = parseInt(storage.disk_percentage)
    diskColor = if diskPercentage > config.thresholds.diskDanger then 'danger' else if diskPercentage > config.thresholds.diskWarning then 'warning' else 'success'

    storageContent = """
      #{helpers.sectionHeaderWithValue("Storage", "#{storage.disk_used} / #{storage.disk_total}", config, config.layout.storageLabelWidth)}
      #{helpers.infoLine(config.icons.diskUsage, "Usage", "#{helpers.createBar(diskPercentage, config, diskColor)} #{storage.disk_percentage}% used", config, config.layout.storageLabelWidth)}
    """

    # Add disk I/O if available
    if storage.disk_read and storage.disk_write and storage.disk_read != "N/A" and storage.disk_write != "N/A"
      diskIOInfo = "↓ #{helpers.colorize(storage.disk_read, 'success', config)} ↑ #{helpers.colorize(storage.disk_write, 'warning', config)}"
      storageContent += helpers.infoLine(config.icons.diskIO, "Disk I/O", diskIOInfo, config, config.layout.storageLabelWidth)

    # Add mount points if available (external drives and network shares only)
    if data.mounts and data.mounts.length > 0
      storageContent += """<div style="margin-top: 8px;">"""
      for mount in data.mounts
        mountPercentage = parseInt(mount.use_percent)
        mountColor = if mountPercentage > 90 then 'danger' else if mountPercentage > 70 then 'warning' else 'text'
        mountInfo = "#{mount.used} / #{mount.size} (#{helpers.colorize(mount.use_percent + '%', mountColor, config)})"

        # Choose icon based on mount type
        mountIcon = switch mount.mount_type
          when 'network' then config.icons.ethernet || '󰈀'
          when 'usb' then config.icons.usb || '󰗮'
          else config.icons.mount || config.icons.disk

        storageContent += helpers.infoLine(mountIcon, mount.name, mountInfo, config, config.layout.storageLabelWidth)
      storageContent += "</div>"

    $('#storageInfo')?.innerHTML = helpers.infoGroup(storageContent)