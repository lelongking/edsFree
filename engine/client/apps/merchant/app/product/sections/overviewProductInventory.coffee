scope = logics.productManagement
Enums = Apps.Merchant.Enums

lemon.defineHyper Template.overviewProductInventory,
  rendered: -> Session.set('productManagementAllowInventory', scope.currentProduct.inventoryInitial)

  helpers:
    currentProduct: -> scope.currentProduct
    upperGapQuality: -> Session.get('productManagementCurrentProduct').qualities[0].upperGapQuality ? 0

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
      if User.hasManagerRoles()
        unless scope.currentProduct.inventoryInitial
          Session.set('productManagementAllowInventory', false)
          Session.set('productManagementInventoryDetails', false)

    "click .allowInventory": (event, template) ->
      if User.hasManagerRoles()
        unless scope.currentProduct.inventoryInitial
          Session.set('productManagementAllowInventory', true)
          details = []
          (details.push {_id : unit._id, quality: 0}) for unit in scope.currentProduct.units
          Session.set('productManagementInventoryDetails', details)

    "keyup [name='upperGapQuality']": (event, template) ->
      $quality = $(template.find("[name='upperGapQuality']"))
#      console.log Number($quality.val())
#      inventoryDetails = Session.get('productManagementInventoryDetails')
#      (detailIndex = index if detail._id is @_id) for detail, index in inventoryDetails
#
      if isNaN(Number($quality.val()))
        $quality.val(Session.get('productManagementCurrentProduct').qualities[0].upperGapQuality)
      else
        Schema.products.update(Session.get('productManagementCurrentProduct')._id, $set:{'qualities.0.upperGapQuality': Number($quality.val())})
#        inventoryDetails[detailIndex].quality = Number($quality.val())
#        Session.set('productManagementInventoryDetails', inventoryDetails)

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
      if User.hasManagerRoles()
        $quality = $(template.find("[name='unitQuality']"))
        inventoryDetails = Session.get('productManagementInventoryDetails')
        (detailIndex = index if detail._id is @_id) for detail, index in inventoryDetails

        if isNaN(Number($quality.val()))
          $quality.val(inventoryDetails[detailIndex].quality)
        else
          inventoryDetails[detailIndex].quality = Number($quality.val())
          Session.set('productManagementInventoryDetails', inventoryDetails)

    "change [name ='deliveryDate']": (event, template) ->
      if User.hasManagerRoles()
        productUnit = @; inventoryDetails = Session.get('productManagementInventoryDetails')
        date = $(template.find("[name='deliveryDate']")).datepicker().data().datepicker.dates[0]

        for detail, index in inventoryDetails
          if detail._id is productUnit._id
            if date then detail.expriceDay = moment(date).endOf("day")._d
            else delete detail.expriceDay
        Session.set('productManagementInventoryDetails', inventoryDetails)