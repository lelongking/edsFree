scope = logics.productManagement
Enums = Apps.Merchant.Enums

lemon.defineHyper Template.overviewProductInventory,
  rendered: -> Session.set('productManagementAllowInventory', scope.currentProduct.inventoryInitial)

  helpers:
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

  events:
    "click .denyInventory": (event, template) ->
      if User.roleIsManager()
        unless scope.currentProduct.inventoryInitial
          Session.set('productManagementAllowInventory', false)
          Session.set('productManagementInventoryDetails', false)

    "click .allowInventory": (event, template) ->
      if User.roleIsManager()
        unless scope.currentProduct.inventoryInitial
          Session.set('productManagementAllowInventory', true)
          details = []
          (details.push {_id : unit._id, quality: 0}) for unit in scope.currentProduct.units
          Session.set('productManagementInventoryDetails', details)

lemon.defineHyper Template.overviewProductInventoryDetail,
  rendered: -> $("[name=deliveryDate]").datepicker()

  helpers:
    currentProduct: -> scope.currentProduct
    quality: ->
      quality = 0
      for unit in Session.get('productManagementInventoryDetails') ? []
        quality = unit.quality if unit._id is @_id
      quality

  events:
    "keyup [name='unitQuality']": (event, template) ->
      if User.roleIsManager()
        $quality = $(template.find("[name='unitQuality']"))
        inventoryDetails = Session.get('productManagementInventoryDetails')
        (detailIndex = index if detail._id is @_id) for detail, index in inventoryDetails

        if isNaN(Number($quality.val()))
          $quality.val(inventoryDetails[detailIndex].quality)
        else
          inventoryDetails[detailIndex].quality = Number($quality.val())
          Session.set('productManagementInventoryDetails', inventoryDetails)

    "change [name ='deliveryDate']": (event, template) ->
      if User.roleIsManager()
        date = $("[name=deliveryDate]").datepicker().data().datepicker.dates[0]
        console.log moment(date).endOf("day")._d

        inventoryDetails = Session.get('productManagementInventoryDetails')
        (detailIndex = index if detail._id is @_id) for detail, index in inventoryDetails

        inventoryDetails[detailIndex].expriceDay = moment(date).endOf("day")._d
        Session.set('productManagementInventoryDetails', inventoryDetails)





