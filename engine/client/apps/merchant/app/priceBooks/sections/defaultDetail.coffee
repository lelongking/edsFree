scope = logics.priceBook

lemon.defineHyper Template.priceBookDetailDefault,
  helpers:
    isPriceBookType: (bookType)->
      priceType = Session.get("currentPriceBook").priceBookType
      return true if bookType is 'default' and priceType is 0
      return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
      return true if bookType is 'provider' and (priceType is 3 or priceType is 4)

    allProductUnits: ->
      scope.findAllProductUnits(@)

    productSelected: ->
      if _.contains(Session.get("priceProductLists"), @_id) then 'selected' else ''

  events:
    "click .detail-row:not(.selected) td.command": (event, template) ->
      scope.currentPriceBook.selectedPriceProduct(@_id)

    "click .detail-row.selected td.command": (event, template) ->
      scope.currentPriceBook.unSelectedPriceProduct(@_id)

    "dblclick .detail-row": (event, template) ->
      Session.set("editingId", @_id)
      event.stopPropagation()


numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign: false}
lemon.defineHyper Template.priceBookDefaultRowEdit,
  rendered: ->
    @ui.$editSaleQuantity.inputmask "numeric", numericOption
    @ui.$editSaleQuantity.val Template.currentData().salePrice

    @ui.$editImportQuantity.inputmask "numeric", numericOption
    @ui.$editImportQuantity.val Template.currentData().importPrice

    @ui.$editSaleQuantity.select()

  events:
    "keyup": (event, template) ->
      product = Template.currentData()

      salePrice = Math.abs(Helpers.Number(template.ui.$editSaleQuantity.inputmask('unmaskedvalue')))
      salePrice = undefined if salePrice is product.salePrice
      importPrice = Math.abs(Helpers.Number(template.ui.$editImportQuantity.inputmask('unmaskedvalue')))
      importPrice = undefined if importPrice is product.importPrice

      console.log product
      if event.which is 13
        if salePrice isnt undefined or importPrice isnt undefined
          scope.currentPriceBook.updatePriceOfProduct(product._id, salePrice, importPrice)
        #          Session.set("editingId", nextRow._id) if nextRow = scope.allProductUnits.getNextBy("_id", productUnit._id)
        Session.set("editingId")
