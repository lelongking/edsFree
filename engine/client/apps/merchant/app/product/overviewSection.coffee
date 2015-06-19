scope = logics.productManagement

lemon.defineHyper Template.productManagementOverviewSection,
  currentProduct: -> scope.currentProduct
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  unitEditingMode: -> Session.get("productManagementUnitEditingRow")?._id is @_id
  unitEditingData: -> Session.get("productManagementUnitEditingRow")

  productUnits: ->
    console.log @units
    for productUnit in @units
      for item in productUnit.priceBooks
        if item.priceBook is Session.get('priceBookBasic')._id
          productUnit.salePrice   = item.salePrice
          productUnit.importPrice = item.importPrice
    @units


#  name: ->
#    Meteor.setTimeout ->
#      scope.overviewTemplateInstance.ui.$productName.change()
#    , 50 if scope.overviewTemplateInstance
#    @name
#
#  price: ->
#    Meteor.setTimeout ->
#      scope.overviewTemplateInstance.ui.$productPrice.inputmask "numeric",
#        {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign:false}
#    , 50 if scope.overviewTemplateInstance
#    @price
#
#  importPrice: ->
#    Meteor.setTimeout ->
#      scope.overviewTemplateInstance.ui.$importPrice.inputmask "numeric",
#        {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign:false}
#    , 50 if scope.overviewTemplateInstance
#    @importPrice
#
  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$productName.autosizeInput({space: 10})
#    @ui.$productPrice.inputmask("numeric",   {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign:false})
#    @ui.$importPrice.inputmask("numeric",   {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign:false})
#
  events:
    "click .avatar": (event, template) -> template.find('.avatarFile').click()
    "change .avatarFile": (event, template) ->
      files = event.target.files
      if files.length > 0
        AvatarImages.insert files[0], (error, fileObj) ->
          Schema.products.update(Session.get('productManagementCurrentProduct')._id, {$set: {image: fileObj._id}})
          AvatarImages.findOne(Session.get('productManagementCurrentProduct').image)?.remove()

    "click .addProductUnit": -> scope.currentProduct.unitCreate()
    "click .deleteProductUnit": -> scope.currentProduct.unitRemove(@_id)
    "click .productDelete": -> scope.currentProduct.remove()

    "click .unitEditBarcode": ->
      unitEditing = @; unitEditing.select = "Barcode"
      Session.set("productManagementUnitEditingRow", unitEditing)

    "click .unitEditName": ->
      unitEditing = @; unitEditing.select = "Name"
      Session.set("productManagementUnitEditingRow", unitEditing)

    "click .unitEditConversion": ->
      unitEditing = @; unitEditing.select = if @isBase then 'SalePrice' else "Conversion"
      Session.set("productManagementUnitEditingRow", unitEditing)

    "click .unitEditImportPrice": ->
      unitEditing = @; unitEditing.select = "ImportPrice"
      Session.set("productManagementUnitEditingRow", unitEditing)

    "click .unitEditSalePrice": ->
      unitEditing = @; unitEditing.select = "SalePrice"
      Session.set("productManagementUnitEditingRow", unitEditing)