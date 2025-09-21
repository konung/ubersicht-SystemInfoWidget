# CPU Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    # CPU is tied to network display setting
    return unless config.display.showNetwork

    hw = data.hardware
    sys = data.system
    cpuUsage = parseFloat(hw.cpu_usage)
    cpuColor = if cpuUsage > config.thresholds.cpuDanger then 'danger' else if cpuUsage > config.thresholds.cpuWarning then 'warning' else 'success'

    # Format CPU header with thread count and colorized usage
    cpuColorHex = switch cpuColor
      when 'danger' then config.appearance.colors.danger
      when 'warning' then config.appearance.colors.warning
      else config.appearance.colors.success
    cpuHeaderValue = "#{hw.cpu} [#{hw.cpu_threads}] (<span style='color: rgb(#{cpuColorHex});'>#{hw.cpu_usage}%</span>)"
    cpuContent = helpers.sectionHeaderWithValue("CPU", cpuHeaderValue, config, config.layout.cpuLabelWidth)

    # Load averages
    if sys.load_avg
      loadValues = sys.load_avg.split(',')
      if loadValues.length == 3
        load1 = parseFloat(loadValues[0])
        load5 = parseFloat(loadValues[1])
        load15 = parseFloat(loadValues[2])

        # Get actual core count from CPU threads
        cores = parseInt(hw.cpu_threads) || 12
        loadColor = if load1 > cores then 'danger' else if load1 > cores * 0.7 then 'warning' else 'success'
        # Format with pipe separators - colorize each value individually
        load1Color = if load1 > cores then 'danger' else if load1 > cores * 0.7 then 'warning' else 'success'
        load5Color = if load5 > cores then 'danger' else if load5 > cores * 0.7 then 'warning' else 'success'
        load15Color = if load15 > cores then 'danger' else if load15 > cores * 0.7 then 'warning' else 'success'
        loadDisplay = "#{helpers.colorize(loadValues[0], load1Color, config)} | #{helpers.colorize(loadValues[1], load5Color, config)} | #{helpers.colorize(loadValues[2], load15Color, config)}"
      else
        loadDisplay = sys.load_avg

      cpuContent += helpers.infoLine(config.icons.cpu, "Load", loadDisplay, config, config.layout.cpuLabelWidth)

    # Top processes
    if data.processes and data.processes.top_cpu and data.processes.top_cpu.length > 0
      cpuContent += """<div style="margin-top: 5px;">"""
      for proc, index in data.processes.top_cpu
        cpuValue = parseFloat(proc.cpu.replace('%', ''))
        procColor = if cpuValue > 50 then 'danger' else if cpuValue > 20 then 'warning' else 'text'
        procLabel = "  #{index + 1}. #{proc.name}"
        cpuContent += helpers.infoLine('', procLabel, helpers.colorize(proc.cpu, procColor, config), config, config.layout.cpuLabelWidth)
      cpuContent += """</div>"""

    $('#processesInfo')?.innerHTML = helpers.infoGroup(cpuContent)