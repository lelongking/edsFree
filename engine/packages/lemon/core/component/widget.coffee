helpers = Component.helpers

lemon.defineWidget = (source, destination) ->
  cloneEssentials(source, destination)

  source.rendered = ->
    helpers.customBinding(destination.ui, @) if destination.ui
    helpers.invokeIfNeccessary(destination.rendered, @)

lemon.defineHyper = (source, destination) ->
  cloneEssentials(source, destination)

  source.rendered = ->
    helpers.customBinding(destination.ui, @) if destination.ui
    helpers.autoBinding(@)
    helpers.invokeIfNeccessary(destination.rendered, @)

exceptions = ['ui', 'rendered', 'helpers']
cloneEssentials = (source, destination) ->
  source[name] = value for name, value of destination when !_(exceptions).contains(name)
  source.helpers(destination.helpers)