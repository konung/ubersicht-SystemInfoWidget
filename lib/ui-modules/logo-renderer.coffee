# Logo Renderer Module

module.exports = (config, helpers) ->
  render: (data, $) ->
    return unless config.display.showLogo

    logoHtml = config.logo.map((line) ->
      "<div>#{helpers.colorize(line, 'accent', config)}</div>"
    ).join('')

    $('#logo')?.innerHTML = logoHtml