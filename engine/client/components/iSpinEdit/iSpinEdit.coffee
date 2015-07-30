registerSpinEdit = ($element, context) ->
  options = {}
  options.initVal = context.data.options.reactiveValue()
  options.min = context.data.options.reactiveMin()
  options.max = context.data.options.reactiveMax()
  options.step = context.data.options.reactiveStep()
  _.extend(options, context.data.options.others) if context.data.options.others

  $element.TouchSpin(options)

startTrackingOptions = ($element, context) ->
  context.optionsTracker = Tracker.autorun ->
    $element.trigger "touchspin.updatesettings",
      max: context.data.options.reactiveMax()
      min: context.data.options.reactiveMin()
      step: context.data.options.reactiveStep()
      initVal: context.data.options.reactiveValue()

stopTrackingOptions = (context) -> context.optionsTracker.stop() if context.optionsTracker

startTrackingValue = ($element, context) ->
  $element.on 'change', (e) ->
    parsedValue = accounting.parse(e.target.value)
    if context.data.options.reactiveSetter
      parsedValue =
        if isValueValid(context, parsedValue) then Number(parsedValue)
        else Number(context.data.options.reactiveValue())
      context.data.options.reactiveSetter(parsedValue)

isValueValid = (context, value) ->
    value >= context.data.options.reactiveMin() &&
    value <= context.data.options.reactiveMax()

lemon.defineWidget Template.iSpinEdit,
  helpers:
    reactiveValue: -> Template.instance().data.options.reactiveValue()
  ui:
    component: "input"

  rendered: ->
    $component = $(@ui.component)
    registerSpinEdit($component, @)
    startTrackingOptions($component, @)
    startTrackingValue($component, @)

  destroyed: -> stopTrackingOptions(@)
