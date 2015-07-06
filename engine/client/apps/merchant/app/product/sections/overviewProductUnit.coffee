scope = logics.productManagement

lemon.defineHyper Template.overviewProductUnit,
  currentProduct: -> scope.currentProduct
  allowCreateUnit: -> if Session.get('productManagementAllowAddUnit') then 'selected' else ''
  isNotLimitUnit: -> Session.get('productManagementAllowAddUnit') and scope.currentProduct.units?.length < 3
  productUnitTables : ->
    unitTable = []
    product =
      isProduct   : true
      name        : scope.currentProduct.name
      barcode     : 'Mã Vạch'
      importPrice : 'Giá Nhập'
      saleQuality : 'Giá Bán'
    unitTable.push(product)

    for unit in scope.currentProduct.units
      productUnit =
        isProduct   : false
        name        : unit.name
        barcode     : unit.barcode
        importPrice : unit.priceBooks[0].importPrice
        saleQuality : unit.priceBooks[0].salePrice
      unitTable.push(productUnit)
    return unitTable

  rendered: ->
    Session.set('productManagementAllowAddUnit', scope.currentProduct.units?.length < 3)

  events:
    "click span.icon-ok-6": ->
      Session.set('productManagementAllowAddUnit', !Session.get('productManagementAllowAddUnit'))


lemon.defineHyper Template.productUnitDetail,
  currentProduct: -> scope.currentProduct
  events:
    "keyup input.editable": (event, template) ->
      console.log $(template.find("[name='productUnitName']")).val()

    "click .deleteProductUnit": (event, template) -> scope.deleteNewProductUnit(@, event, template)

lemon.defineHyper Template.productUnitCreateUnit,
  currentProduct: -> scope.currentProduct
  events:
    "click .addProductUnit": (event, template) -> scope.createNewProductUnit(event, template)


#
#
#    "click .addProductUnit": -> scope.currentProduct.unitCreate()
#    "click .deleteProductUnit": -> scope.currentProduct.unitRemove(@_id)
#    "click .productDelete": -> scope.currentProduct.remove()
#
#    "click .unitEditBarcode": ->
#      unitEditing = @; unitEditing.select = "Barcode"
#      Session.set("productManagementUnitEditingRow", unitEditing)
#
#    "click .unitEditName": ->
#      unitEditing = @; unitEditing.select = "Name"
#      Session.set("productManagementUnitEditingRow", unitEditing)
#
#    "click .unitEditConversion": ->
#      unitEditing = @; unitEditing.select = if @isBase then 'SalePrice' else "Conversion"
#      Session.set("productManagementUnitEditingRow", unitEditing)
#
#    "click .unitEditImportPrice": ->
#      unitEditing = @; unitEditing.select = "ImportPrice"
#      Session.set("productManagementUnitEditingRow", unitEditing)
#
#    "click .unitEditSalePrice": ->
#      unitEditing = @; unitEditing.select = "SalePrice"
#      Session.set("productManagementUnitEditingRow", unitEditing)