scope = logics.productManagement
Enums = Apps.Merchant.Enums

lemon.defineHyper Template.overviewProductUnit,
  helpers:
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
          _id         : unit._id
          class       : 'unit'
          isProduct   : false
          name        : unit.name
          barcode     : unit.barcode
          importPrice : unit.priceBooks[0].importPrice
          saleQuality : unit.priceBooks[0].salePrice
        unitTable.push(productUnit)
      return unitTable

  rendered: ->
    if scope.currentProduct.status is Enums.getValue('ProductStatuses', 'initialize')
      Session.set('productManagementAllowAddUnit', scope.currentProduct.units?.length < 3)
    else
      Session.set('productManagementAllowAddUnit', false)

  events:
    "click span.icon-ok-6": ->
      Session.set('productManagementAllowAddUnit', !Session.get('productManagementAllowAddUnit'))


lemon.defineHyper Template.productUnitTableDetail,
  isEditImportPrice: -> scope.currentProduct.status isnt Enums.getValue('ProductStatuses', 'confirmed')
  events:
    "keyup [name='editImportQuality']": (event, template) ->
      $importPrice  = template.ui.$editImportQuality
      console.log accounting.parse($importPrice.val()), @_id
      if event.which is 13
        updateOption = {importPrice: accounting.parse($importPrice.val())}
        scope.currentProduct.unitUpdate @_id, updateOption

lemon.defineHyper Template.overviewProductInventoryDetail,
  currentProduct: -> scope.currentProduct
  quality: ->
    quality = 0
    for unit in Session.get('productManagementInventoryDetails')
      quality = unit.quality if unit._id is @_id
    quality


  rendered: -> $("[name=deliveryDate]").datepicker()
  events:
    "keyup [name='unitQuality']": (event, template) ->
      $quality = $(template.find("[name='unitQuality']"))
      inventoryDetails = Session.get('productManagementInventoryDetails')
      (detailIndex = index if detail._id is @_id) for detail, index in inventoryDetails

      if isNaN(Number($quality.val()))
        $quality.val(inventoryDetails[detailIndex].quality)
      else
        inventoryDetails[detailIndex].quality = Number($quality.val())
        Session.set('productManagementInventoryDetails', inventoryDetails)



lemon.defineHyper Template.overviewProductInventory,
  currentProduct: -> scope.currentProduct
  importUnit: ->
    importUnitFound = {quality:0}
    if importDetails = Schema.imports.findOne({importType: -2, 'details.productUnit': @_id})?.details
      (importUnitFound = importUnit if importUnit.productUnit is @_id) for importUnit in importDetails
    return importUnitFound

  isImport: (status)->
    if status is 'sale'
      if Session.get('productManagementAllowInventory') then '' else 'selected'
    else
      if Session.get('productManagementAllowInventory') then 'selected' else ''

  rendered: ->
    Session.set('productManagementAllowInventory', scope.currentProduct.inventoryInitial)

  events:
    "click .denyInventory": (event, template) ->
      unless scope.currentProduct.inventoryInitial
        Session.set('productManagementAllowInventory', false)
        Session.set('productManagementInventoryDetails', false)

    "click .allowInventory": (event, template) ->
      unless scope.currentProduct.inventoryInitial
        Session.set('productManagementAllowInventory', true)
        details = []
        (details.push {_id : unit._id, quality: 0}) for unit in scope.currentProduct.units
        Session.set('productManagementInventoryDetails', details)


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
