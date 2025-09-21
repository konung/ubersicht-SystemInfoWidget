# Network Traffic Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showNetwork

    net = data.network

    # Create traffic section content
    trafficContent = ""
    trafficContent += helpers.sectionHeaderWithValue("Traffic", "", config, config.layout.trafficLabelWidth)

    # Traffic rates
    trafficInfo = "↓ #{helpers.colorize(net.traffic_down, 'success', config)} ↑ #{helpers.colorize(net.traffic_up, 'warning', config)}"
    trafficContent += helpers.infoLine(config.icons.traffic, "Speed", trafficInfo, config, config.layout.trafficLabelWidth)

    # Active connections if available
    if net.connections?
      connectionColor = if net.connections > 100 then 'warning' else if net.connections > 200 then 'danger' else 'text'
      trafficContent += helpers.infoLine(config.icons.connections, "Connections", helpers.colorize("#{net.connections} active", connectionColor, config), config, config.layout.trafficLabelWidth)

    # Ping if available
    if net.ping and net.ping != "N/A"
      pingValue = parseFloat(net.ping)
      pingColor = if pingValue < config.thresholds.pingGood then 'success' else if pingValue < config.thresholds.pingWarning then 'warning' else 'danger'
      trafficContent += helpers.infoLine(config.icons.ping, "Latency", "#{helpers.colorize(net.ping, pingColor, config)} (#{net.ping_target})", config, config.layout.trafficLabelWidth)

    # Network apps section - just list top consumers
    if config.display.showNetworkApps and net.apps and net.apps.length > 0
      trafficContent += "<div style=\"margin-top: 8px;\">"

      for app, index in net.apps
        # Apps already have formatted down/up strings
        appTraffic = "↓ #{helpers.colorize(app.down, 'success', config)} ↑ #{helpers.colorize(app.up, 'warning', config)}"
        appLabel = "  #{index + 1}. #{app.name}"
        trafficContent += helpers.infoLine('', appLabel, appTraffic, config, config.layout.trafficLabelWidth)

      trafficContent += "</div>"

    $('#trafficInfo')?.innerHTML = helpers.infoGroup(trafficContent)
