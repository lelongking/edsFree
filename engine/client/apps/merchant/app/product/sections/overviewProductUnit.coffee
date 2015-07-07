scope = logics.productManagement

lemon.defineHyper Template.overviewProductUnit,
  currentProduct: -> scope.currentProduct
  allowCreateUnit: -> if Session.get('productManagementAllowAddUnit') then 'selected' else ''
  isNotLimitUnit: -> Session.get('productManagementAllowAddUnit') and scope.currentProduct.units?.length < 3
  productUnitTables : ->
    unitTable = []
    product =
      class       : 'product'
      isProduct   : true
      name        : scope.currentProduct.name
      barcode     : 'Mã Vạch'
      importPrice : 'Giá Nhập'
      saleQuality : 'Giá Bán'
    unitTable.push(product)

    for unit in scope.currentProduct.units
      productUnit =
        class       : 'unit'
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


lemon.defineHyper Template.overviewProductInventoryDetail,
  currentProduct: -> scope.currentProduct
  quality: -> 0
  rendered: -> $("[name=deliveryDate]").datepicker()
  events:
    "keyup [name='unitQuality']": (event, template) ->
      $quality = $(template.find("[name='unitQuality']"))
      if isNaN(Number($quality.val())) then $quality.val(@conversion)


lemon.defineHyper Template.overviewProductInventory,
  currentProduct: -> scope.currentProduct
  isImport: (status)->
    if status is 'sale'
      if Session.get('productManagementAllowInventory') then '' else 'selected'
    else
      if Session.get('productManagementAllowInventory') then 'selected' else ''

  rendered: ->
    Session.set('productManagementAllowInventory', true)

  events:
    "click .denyInventory": (event, template) -> Session.set('productManagementAllowInventory', false)
    "click .allowInventory": (event, template) -> Session.set('productManagementAllowInventory', true)

lemon.defineHyper Template.productUnitDetail,
  currentProduct: -> scope.currentProduct
  events:
    "keyup [name='productUnitName']": (event, template) ->
      console.log $(template.find("[name='productUnitName']")).val()
      scope.currentProduct.unitUpdate(@_id, {name: $(template.find("[name='productUnitName']")).val()})

    "keyup [name='productUnitConversion']": (event, template) ->
      $conversion = $(template.find("[name='productUnitConversion']"))
      if isNaN(Number($conversion.val())) then $conversion.val(@conversion)
      else scope.currentProduct.unitUpdate(@_id, {conversion: $conversion.val()})

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