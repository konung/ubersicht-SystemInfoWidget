# Network Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showNetwork

    net = data.network
    sys = data.system

    username = if config.display.privacyMode then "user" else sys.username
    networkContent = helpers.sectionHeaderWithValue("Network Info", "#{username}@#{sys.hostname}", config, config.layout.networkLabelWidth)
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

        # Add descriptive labels to interfaces
        displayName = iface.name

        # Check for Tailscale specifically (100.x.x.x addresses)
        if iface.ip and iface.ip.startsWith('100.')
          displayName = "#{iface.name} (Tailscale)"
          icon = config.icons.tailscale if config.icons.tailscale
        else
          switch iface.type
            when 'wifi'
              if net.wifi_ssid and net.wifi_ssid != ''
                displayName = "Wi-Fi (#{net.wifi_ssid})"
              else
                displayName = "#{iface.name} (Wi-Fi)"
            when 'ethernet'
              displayName = "#{iface.name} (Ethernet)"
            when 'vpn'
              displayName = "#{iface.name} (VPN)"
            when 'bridge'
              # Bridge interfaces are typically Docker-related
              if iface.name.match(/^bridge\d+$/)
                displayName = "#{iface.name} (Docker)"
                icon = config.icons.docker if config.icons.docker
              else
                displayName = "#{iface.name} (Bridge)"
            when 'vm'
              displayName = "#{iface.name} (VM)"
            when 'docker'
              displayName = "#{iface.name} (Docker)"
            when 'airdrop'
              displayName = "#{iface.name} (AirDrop)"
        networkContent += helpers.infoLine(icon, displayName, iface.ip, config, config.layout.networkLabelWidth)

    # Public IP info
    networkContent += helpers.infoLine(config.icons.publicIp, "Public IP", net.public_ip, config, config.layout.networkLabelWidth)
    if net.public_hostname and net.public_hostname != ""
      networkContent += helpers.infoLine(config.icons.publicIp, "Public FQDN", net.public_hostname, config, config.layout.networkLabelWidth)
    if net.public_location and net.public_location != ""
      networkContent += helpers.infoLine(config.icons.publicLocation, "Location", net.public_location, config, config.layout.networkLabelWidth)
    if net.public_org and net.public_org != ""
      networkContent += helpers.infoLine(config.icons.isp, "ISP", net.public_org, config, config.layout.networkLabelWidth)


    $('#networkInfo')?.innerHTML = helpers.infoGroup(networkContent)
