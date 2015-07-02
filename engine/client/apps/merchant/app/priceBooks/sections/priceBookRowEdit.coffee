scope = logics.priceBook
lemon.defineHyper Template.priceBookRowEdit,
  isPriceBookType: (bookType)->
    priceType = Session.get("currentPriceBook").priceBookType
    return true if bookType is 'default' and priceType is 0
    return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
    return true if bookType is 'provider' and (priceType is 3 or priceType is 4)

  rendered: ->
    if _.contains([0, 1, 2], Template.currentData().priceBookType)
      @ui.$editSaleQuality.inputmask "numeric",
        {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
      @ui.$editSaleQuality.val Template.currentData().salePrice

    if _.contains([0, 3, 4], Template.currentData().priceBookType)
      @ui.$editImportQuality.inputmask "numeric",
        {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
      @ui.$editImportQuality.val Template.currentData().importPrice

    if _.contains([0, 1, 2], Template.currentData().priceBookType)
      @ui.$editSaleQuality.select()
    else
      @ui.$editImportQuality.select()

  events:
    "keyup": (event, template) ->
      productUnit = Template.currentData()
      if _.contains([0, 1, 2], productUnit.priceBookType)
        salePrice = Math.abs(Helpers.Number(template.ui.$editSaleQuality.inputmask('unmaskedvalue')))
        salePrice = undefined if salePrice is productUnit.salePrice

      if _.contains([0, 3, 4], productUnit.priceBookType)
        importPrice = Math.abs(Helpers.Number(template.ui.$editImportQuality.inputmask('unmaskedvalue')))
        importPrice = undefined if importPrice is productUnit.importPrice

      if event.which is 13
        if salePrice isnt undefined or importPrice isnt undefined
          scope.currentPriceBook.updateProductUnitPrice(productUnit._id, salePrice, importPrice)
          Session.set("editingId", nextRow._id) if nextRow = scope.allProductUnits.getNextBy("_id", productUnit._id)
        else
          Session.set("editingId")
      else if event.which is 40  #downArrow
        Session.set("editingId", nextRow._id) if nextRow = scope.allProductUnits.getNextBy("_id", productUnit._id)
      else if event.which is 38  #upArrow
        Session.set("editingId", previousRow._id) if previousRow = scope.allProductUnits.getPreviousBy("_id", productUnit._id)

lemon.defineHyper Template.priceBookRowDisplay,
  isPriceBookType: (bookType)->
    priceType = Session.get("currentPriceBook").priceBookType
    return true if bookType is 'default' and priceType is 0
    return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
    return true if bookType is 'provider' and (priceType is 3 or priceType is 4)


lemon.defineHyper Template.priceBookDefaultRowEdit,
  rendered: ->
    @ui.$editSaleQuality.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign: false}
    @ui.$editSaleQuality.val Template.currentData().salePrice

    @ui.$editImportQuality.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign: false}
    @ui.$editImportQuality.val Template.currentData().importPrice

    @ui.$editSaleQuality.select()

  events:
    "keyup": (event, template) ->
      productUnit = Template.currentData()

      salePrice = Math.abs(Helpers.Number(template.ui.$editSaleQuality.inputmask('unmaskedvalue')))
      salePrice = undefined if salePrice is productUnit.salePrice
      importPrice = Math.abs(Helpers.Number(template.ui.$editImportQuality.inputmask('unmaskedvalue')))
      importPrice = undefined if importPrice is productUnit.importPrice

      if event.which is 13
        if salePrice isnt undefined or importPrice isnt undefined
          scope.currentPriceBook.updateProductUnitPrice(productUnit._id, salePrice, importPrice)
#          Session.set("editingId", nextRow._id) if nextRow = scope.allProductUnits.getNextBy("_id", productUnit._id)
        Session.set("editingId")

lemon.defineHyper Template.priceBookCustomerRowEdit,
  isGroup: -> Session.get("currentPriceBook").priceBookType is 2
  rendered: ->
    @ui.$editSaleQuality.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign: false}
    @ui.$editSaleQuality.val Template.currentData().salePrice

    @ui.$editSaleQuality.select()

  events:
    "keyup": (event, template) ->
      productUnit = Template.currentData()
      salePrice = Math.abs(Helpers.Number(template.ui.$editSaleQuality.inputmask('unmaskedvalue')))
      salePrice = undefined if salePrice is productUnit.salePrice

      if event.which is 13
        if salePrice isnt undefined
          scope.currentPriceBook.updateProductUnitPrice(productUnit._id, salePrice)
#          Session.set("editingId", nextRow._id) if nextRow = scope.allProductUnits.getNextBy("_id", productUnit._id)
        Session.set("editingId")