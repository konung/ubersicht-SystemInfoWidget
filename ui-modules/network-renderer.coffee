# Network Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showNetwork

    net = data.network
    sys = data.system

    networkContent = helpers.sectionHeader("Network Info")
    networkContent += helpers.infoLine(config.icons.host, "Hostname", sys.hostname, config, config.layout.networkLabelWidth)
    networkContent += helpers.infoLine(config.icons.host, "FQDN", sys.full_hostname, config, config.layout.networkLabelWidth)

    # Network interfaces
    if net.interfaces and net.interfaces.length > 0
      for iface in net.interfaces
        icon = switch iface.type
          when 'wifi' then config.icons.wifi
          when 'ethernet' then config.icons.ethernet
          when 'tailscale' then config.icons.tailscale
          when 'vpn' then config.icons.vpn
          when 'docker' then config.icons.docker
          when 'bridge' then config.icons.bridge
          when 'vm' then config.icons.vm
          when 'parallels' then config.icons.parallels
          when 'virtualbox' then config.icons.virtualbox
          when 'hotspot' then config.icons.hotspot
          when 'airdrop' then config.icons.airdrop
          else config.icons.default

        displayName = iface.name
        if iface.type == 'wifi' and net.wifi_ssid and net.wifi_ssid != ''
          displayName = "Wi-Fi (#{net.wifi_ssid})"
        networkContent += helpers.infoLine(icon, displayName, iface.ip, config, config.layout.networkLabelWidth)

    # Public IP info
    networkContent += helpers.infoLine(config.icons.publicIp, "Public IP", net.public_ip, config, config.layout.networkLabelWidth)
    if net.public_hostname and net.public_hostname != ""
      networkContent += helpers.infoLine(config.icons.publicIp, "Public FQDN", net.public_hostname, config, config.layout.networkLabelWidth)
    if net.public_location and net.public_location != ""
      networkContent += helpers.infoLine(config.icons.publicLocation, "Location", net.public_location, config, config.layout.networkLabelWidth)
    if net.public_org and net.public_org != ""
      networkContent += helpers.infoLine(config.icons.isp, "ISP", net.public_org, config, config.layout.networkLabelWidth)

    # Ping
    if net.ping and net.ping != 'N/A'
      pingValue = parseFloat(net.ping)
      pingColor = if pingValue > config.thresholds.pingWarning then 'danger' else if pingValue > config.thresholds.pingGood then 'warning' else 'success'
      pingTarget = net.ping_target or '8.8.8.8'
      networkContent += helpers.infoLine(config.icons.ping, "Ping (#{pingTarget})", helpers.colorize(net.ping , pingColor, config), config, config.layout.networkLabelWidth)

    # Network traffic
    if net.traffic_down and net.traffic_up
      trafficInfo = "↓ #{helpers.colorize(net.traffic_down, 'success', config)} ↑ #{helpers.colorize(net.traffic_up, 'warning', config)}"
      networkContent += helpers.infoLine(config.icons.traffic, "Traffic", trafficInfo, config, config.layout.networkLabelWidth)

    # Top network apps
    if config.display.showNetworkApps and net.apps and net.apps.length > 0
      networkContent += """<div style="margin-top: 8px;">"""
      for app, index in net.apps
        appTraffic = "↓ #{helpers.colorize(app.down, 'success', config)} ↑ #{helpers.colorize(app.up, 'warning', config)}"
        appLabel = "  #{index + 1}. #{app.name}"
        networkContent += helpers.infoLine('', appLabel, appTraffic, config, config.layout.networkLabelWidth)
      networkContent += """</div>"""

    $('#networkInfo')?.innerHTML = helpers.infoGroup(networkContent)
