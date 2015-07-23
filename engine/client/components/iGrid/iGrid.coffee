lemon.defineWidget Template.iGrid,
  helpers:
    itemTemplate: ->
      template = Template.instance()
      itemTemplate = template.data.options.itemTemplate
      if typeof itemTemplate is 'function' then itemTemplate(@) else itemTemplate
    dataSource: -> Template.instance().data.options.reactiveSourceGetter()
    classicalHeader: -> Template.instance().data.options.classicalHeader
  created: ->
    console.log Template.instance()
