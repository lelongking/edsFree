scope = logics.warehouse

lemon.defineApp Template.warehouse,
  created: ->
    Session.set('warehouseShowAll', true)

  helpers:
    listProductsTrade: -> scope.listProductsTrade().details
    listProductsNotTrade: -> scope.listProductsNotTrade(scope.listProductsTrade().details.length).details

    totalCostPrice: ->
      scope.listProductsTrade().totalCostPrice
    totalRevenue: ->
      scope.listProductsTrade().totalRevenue

  events:
    "keyup input.upperGap":  (event, template) ->
      console.log @
      upperGap = Number(template.ui["$#{@_id}"].val())
      Schema.products.update @_id, $set:{'quantities.0.normsQuantity': upperGap}