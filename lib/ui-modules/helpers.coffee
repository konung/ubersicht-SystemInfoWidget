# Helper functions module for SystemInfoWidget

module.exports =
  colorize: (text, type = 'accent', config) ->
    colors = config.appearance.colors
    colorMap = {
      'accent': colors.accent
      'success': colors.success
      'warning': colors.warning
      'danger': colors.danger
      'text': colors.text
      'muted': colors.muted
    }
    color = colorMap[type] or colors.text
    "<span style='color: rgb(#{color})'>#{text}</span>"

  sectionHeader: (title) ->
    """<div class="info-line">
      <span class="section-header">#{title}</span>
    </div>"""

  sectionHeaderWithValue: (title, value, config, labelWidth = null, textAlign = null) ->
    width = labelWidth ? config.layout.defaultLabelWidth
    align = textAlign ? config.layout.defaultLabelTextAlign
    """<div class="info-line">
      <span class="label section-header" style='min-width: #{width}px; display: inline-block; text-align: #{align};'>#{title}</span>
      <span class="value">#{value}</span>
    </div>"""

  infoLine: (icon, label, value, config, labelWidth = null, textAlign = null) ->
    width = labelWidth ? config.layout.defaultLabelWidth
    align = textAlign ? config.layout.defaultLabelTextAlign
    widthStyle = "style='min-width: #{width}px; display: inline-block; text-align: #{align};'"
    labelText = if icon
      "<span style='font-size: #{config.appearance.iconFontSize}px; margin: 10px 4px 0 0; line-height: 1.1;'>#{icon}</span>#{label}"
    else
      label
    """<div class="info-line">
      <span class="label" #{widthStyle}>#{labelText}</span>
      <span class="value">#{value}</span>
    </div>"""

  infoGroup: (content) ->
    """<div class="info-group">#{content}</div>"""

  createBar: (percentage, config, color) ->
    filled = Math.round(percentage * config.progressBar.width / 100)
    empty = config.progressBar.width - filled
    bar = config.progressBar.filled.repeat(filled) + config.progressBar.empty.repeat(empty)
    @colorize(bar, color, config)

  formatBytes: (bytes) ->
    if bytes < 1024
      [bytes, 'B/s']
    else if bytes < 1024 * 1024
      [bytes / 1024, 'KB/s']
    else if bytes < 1024 * 1024 * 1024
      [bytes / 1024 / 1024, 'MB/s']
    else
      [bytes / 1024 / 1024 / 1024, 'GB/s']
