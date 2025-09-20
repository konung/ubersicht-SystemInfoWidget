# Main Widget Renderer - Orchestrates all sub-renderers

module.exports = (config) ->
  # Load all modules
  helpers = require('./helpers.coffee')
  logoRenderer = require('./logo-renderer.coffee')(config, helpers)
  systemRenderer = require('./system-renderer.coffee')(config, helpers)
  networkRenderer = require('./network-renderer.coffee')(config, helpers)
  storageRenderer = require('./storage-renderer.coffee')(config, helpers)
  cpuRenderer = require('./cpu-renderer.coffee')(config, helpers)
  devRenderer = require('./dev-renderer.coffee')(config, helpers)

  renderAll: (data, domEl) ->
    # Use querySelector from domEl
    $ = (selector) -> domEl.querySelector(selector)

    # Render all sections
    logoRenderer.render(data, $)
    systemRenderer.render(data, $)
    storageRenderer.render(data, $)
    networkRenderer.render(data, $)
    cpuRenderer.render(data, $)
    devRenderer.render(data, $)

  # Generate the initial HTML template
  generateTemplate: ->
    # Conditionally include the logo column
    logoColumn = if config.display.showLogo
      """
      <div class="column column-1">
        <div class="logo-section" id="logo"></div>
      </div>
      """
    else
      ""

    # Return the complete widget HTML
    """
    <div class="widget-wrapper" style="
      position: fixed;
      top: #{config.position.top}px;
      left: #{config.position.left}px;
      right: #{config.position.right};
      bottom: #{config.position.bottom};
      font-family: #{config.appearance.fontFamily};
      font-size: #{config.appearance.fontSize}px;
      color: rgb(#{config.appearance.colors.text});
    ">
      <div class="container" style="
        background: rgba(#{config.appearance.colors.background}, #{config.appearance.backgroundOpacity});
        backdrop-filter: blur(#{config.appearance.backgroundBlur}px);
        -webkit-backdrop-filter: blur(#{config.appearance.backgroundBlur}px);
        border-radius: #{config.appearance.borderRadius}px;
        padding: #{config.appearance.padding}px;
        box-shadow: #{config.appearance.boxShadow};
      ">
        <div class="main-content">
          #{logoColumn}
          <div class="column column-2">
            <div class="system-info" id="systemInfo"></div>
            <div class="storage-info" id="storageInfo"></div>
            <div class="summary-info" id="summaryInfo"></div>
          </div>
          <div class="column column-3">
            <div class="network-info" id="networkInfo"></div>
            <div class="cpu-info" id="cpuInfo"></div>
          </div>
          <div class="column column-4">
            <div class="dev-info" id="devInfo"></div>
          </div>
        </div>
      </div>
    </div>
    """