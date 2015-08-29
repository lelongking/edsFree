scope = logics.merchantOptions

lemon.defineAppContainer Template.merchantOptions,
  helpers:
    settings: -> scope.settings
    currentSectionDynamic: -> Session.get("merchantOptionsCurrentDynamics")
    optionActiveClass: -> if @template is Session.get("merchantOptionsCurrentDynamics")?.template then 'active' else ''
#    settings: -> scope.settings

  rendered: -> console.log 'rendered'
  events:
    "click .caption.inner": -> Session.set("merchantOptionsCurrentDynamics", @)