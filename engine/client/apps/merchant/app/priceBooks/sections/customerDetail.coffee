scope = logics.priceBook

lemon.defineHyper Template.priceBookDetailCustomer,
  helpers:
    isGroup: ->
      Session.get("currentPriceBook").priceBookType is 2

    allProductUnits: ->
      scope.findAllProductUnits(@)

    productSelected: ->
      if _.contains(Session.get("priceProductLists"), @_id) then 'selected' else ''

  events:
    "click .detail-row:not(.selected) td.command": (event, template) ->
      scope.currentPriceBook.selectedPriceProduct(@_id)

    "click .detail-row.selected td.command": (event, template) ->
      scope.currentPriceBook.unSelectedPriceProduct(@_id)

    "click .deleteUnitPrice": (event, template) ->
      scope.currentPriceBook.deletePriceOfProduct(@_id)
      Session.set("editingId")

    "dblclick .detail-row": (event, template) ->
      Session.set("editingId", @_id)
      event.stopPropagation()



lemon.defineHyper Template.priceBookCustomerRowEdit,
  helpers:
    isGroup: -> Session.get("currentPriceBook").priceBookType is 2

  rendered: ->
    @ui.$editSaleQuantity.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign: false}
    @ui.$editSaleQuantity.val Template.currentData().salePrice

    @ui.$editSaleQuantity.select()

  events:
    "keyup": (event, template) ->
      product = Template.currentData()
      salePrice = Math.abs(Helpers.Number(template.ui.$editSaleQuantity.inputmask('unmaskedvalue')))
      salePrice = undefined if salePrice is product.salePrice

      if event.which is 13
        console.log salePrice
        scope.currentPriceBook.updatePriceOfProduct(product._id, salePrice) if salePrice isnt undefined
        Session.set("editingId")
