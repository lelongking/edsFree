lemon.defineWidget Template.gridComponent,
  helpers:
    itemTemplate: ->
      template = Template.instance()
      itemTemplate = template.data.options.itemTemplate
      if typeof itemTemplate is 'function' then itemTemplate(@) else itemTemplate
    dataSource: -> @dataSource ? Template.instance().data.options.reactiveSourceGetter()
    classicalHeader: -> Template.instance().data.options.classicalHeader
    animationClass: ->
      animate = Template.instance().data.animation
      if animate then "animated #{animate}" else ''