scope = logics.priceBook
lemon.defineHyper Template.priceBookRowEdit,
  helpers:
    isPriceBookType: (bookType)->
      priceType = Session.get("currentPriceBook").priceBookType
      return true if bookType is 'default' and priceType is 0
      return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
      return true if bookType is 'provider' and (priceType is 3 or priceType is 4)

  rendered: ->
    if _.contains([0, 1, 2], Template.currentData().priceBookType)
      @ui.$editSaleQuantity.inputmask "numeric",
        {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
      @ui.$editSaleQuantity.val Template.currentData().salePrice

    if _.contains([0, 3, 4], Template.currentData().priceBookType)
      @ui.$editImportQuantity.inputmask "numeric",
        {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
      @ui.$editImportQuantity.val Template.currentData().importPrice

    if _.contains([0, 1, 2], Template.currentData().priceBookType)
      @ui.$editSaleQuantity.select()
    else
      @ui.$editImportQuantity.select()

  events:
    "keyup": (event, template) ->
      product = Template.currentData()
      if _.contains([0, 1, 2], product.priceBookType)
        salePrice = Math.abs(Helpers.Number(template.ui.$editSaleQuantity.inputmask('unmaskedvalue')))
        salePrice = undefined if salePrice is product.salePrice

      if _.contains([0, 3, 4], product.priceBookType)
        importPrice = Math.abs(Helpers.Number(template.ui.$editImportQuantity.inputmask('unmaskedvalue')))
        importPrice = undefined if importPrice is product.importPrice

      if event.which is 13
        if salePrice isnt undefined or importPrice isnt undefined
          scope.currentPriceBook.updatePriceOfProduct(product._id, salePrice, importPrice)
          Session.set("editingId", nextRow._id) if nextRow = scope.allProductUnits.getNextBy("_id", product._id)
        else
          Session.set("editingId")
      else if event.which is 40  #downArrow
        Session.set("editingId", nextRow._id) if nextRow = scope.allProductUnits.getNextBy("_id", product._id)
      else if event.which is 38  #upArrow
        Session.set("editingId", previousRow._id) if previousRow = scope.allProductUnits.getPreviousBy("_id", product._id)

lemon.defineHyper Template.priceBookRowDisplay,
  helpers:
    isPriceBookType: (bookType)->
      priceType = Session.get("currentPriceBook").priceBookType
      return true if bookType is 'default' and priceType is 0
      return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
      return true if bookType is 'provider' and (priceType is 3 or priceType is 4)

