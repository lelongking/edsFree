scope = logics.productManagement
Enums = Apps.Merchant.Enums

lemon.defineHyper Template.overviewProductUnit,
  rendered: ->
    if scope.currentProduct.status is Enums.getValue('ProductStatuses', 'initialize')
      Session.set('productManagementAllowAddUnit', scope.currentProduct.units?.length < 3)
    else
      Session.set('productManagementAllowAddUnit', false)

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

  events:
    "click span.icon-ok-6": ->
      Session.set('productManagementAllowAddUnit', !Session.get('productManagementAllowAddUnit')) if User.roleIsManager()


lemon.defineHyper Template.productUnitTableDetail,
  helpers:
    isEditImportPrice: -> scope.currentProduct.status isnt Enums.getValue('ProductStatuses', 'confirmed')

  events:
    "keyup [name='editImportQuality']": (event, template) ->
      if User.roleIsManager()
        $importPrice  = template.ui.$editImportQuality
        console.log accounting.parse($importPrice.val()), @_id
        if event.which is 13
          updateOption = {importPrice: accounting.parse($importPrice.val())}
          scope.currentProduct.unitUpdate @_id, updateOption

lemon.defineHyper Template.productUnitDetail,
  helpers:
    currentProduct: -> scope.currentProduct

  events:
    "keyup [name='productUnitName']": (event, template) ->
      if User.roleIsManager()
        console.log $(template.find("[name='productUnitName']")).val()
        scope.currentProduct.unitUpdate(@_id, {name: $(template.find("[name='productUnitName']")).val()})

    "keyup [name='productUnitConversion']": (event, template) ->
      if User.roleIsManager()
        $conversion = $(template.find("[name='productUnitConversion']"))
        if isNaN(Number($conversion.val())) then $conversion.val(@conversion)
        else scope.currentProduct.unitUpdate(@_id, {conversion: $conversion.val()})

    "click .deleteProductUnit": (event, template) -> scope.deleteNewProductUnit(@, event, template) if User.roleIsManager()

lemon.defineHyper Template.productUnitCreateUnit,
  helpers:
    currentProduct: -> scope.currentProduct

  events:
    "click .addProductUnit": (event, template) -> scope.createNewProductUnit(event, template) if User.roleIsManager()
