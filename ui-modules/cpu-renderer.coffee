# CPU Information Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    # CPU is tied to network display setting
    return unless config.display.showNetwork

    hw = data.hardware
    cpuUsage = parseFloat(hw.cpu_usage)
    cpuColor = if cpuUsage > config.thresholds.cpuDanger then 'danger' else if cpuUsage > config.thresholds.cpuWarning then 'warning' else 'success'

    cpuContent = helpers.sectionHeader("CPU Info")
    cpuContent += helpers.infoLine(config.icons.cpu, "CPU", "#{hw.cpu} [#{hw.cpu_threads}] (#{helpers.colorize(hw.cpu_usage + '%', cpuColor, config)})", config, config.layout.networkLabelWidth)

    # Top processes
    if data.processes and data.processes.top_cpu and data.processes.top_cpu.length > 0
      cpuContent += """<div style="margin-top: 5px;">"""
      for proc, index in data.processes.top_cpu
        cpuValue = parseFloat(proc.cpu.replace('%', ''))
        procColor = if cpuValue > 50 then 'danger' else if cpuValue > 20 then 'warning' else 'text'
        procLabel = "  #{index + 1}. #{proc.name}"
        cpuContent += helpers.infoLine('', procLabel, helpers.colorize(proc.cpu, procColor, config), config, config.layout.networkLabelWidth)
      cpuContent += """</div>"""

    $('#cpuInfo')?.innerHTML = helpers.infoGroup(cpuContent)