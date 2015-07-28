scope = logics.productGroup

lemon.defineHyper Template.productGroupDetailSection,
  helpers:
    lastExpireDays: -> if @lastExpire then moment(@lastExpire).diff(new Date(), 'days') + ' Ngày' else '--- Ngày'
    selected: -> if _.contains(Session.get("productSelectLists"), @_id) then 'selected' else ''
    productLists: ->
      return [] if !@products or @products.length is 0
      Schema.products.find({_id: {$in: @products}, group: @_id},{sort: {name: 1}})
  rendered: ->

  events:
    "click .detail-row:not(.selected) td.command": (event, template) -> scope.currentProductGroup.selectedProduct(@_id)
    "click .detail-row.selected td.command": (event, template) -> scope.currentProductGroup.unSelectedProduct(@_id)