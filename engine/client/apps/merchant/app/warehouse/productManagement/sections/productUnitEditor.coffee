scope = logics.productManagement
lemon.defineHyper Template.productManagementUnitEditor,
  changeConversion: -> @allowDelete and !@isBase

  rendered: ->
    @ui.$salePrice.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", suffix: " VNĐ", radixPoint: ".", integerDigits:11}
    @ui.$salePrice.val Session.get("productManagementUnitEditingRow").salePrice

    @ui.$importPrice.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", suffix: " VNĐ", radixPoint: ".", integerDigits:11}
    @ui.$importPrice.val Session.get("productManagementUnitEditingRow").importPrice

    @ui.$conversion?.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", suffix: " #{scope.currentProduct.unitName}", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$conversion?.val Session.get("productManagementUnitEditingRow").conversion

    if Session.get("productManagementUnitEditingRow").select is 'Barcode'
      @ui.$barcode.select()
    else if Session.get("productManagementUnitEditingRow").select is 'Name'
      @ui.$unitName.select()
    else if Session.get("productManagementUnitEditingRow").select is 'Conversion'
      @ui.$conversion.select()
    else if Session.get("productManagementUnitEditingRow").select is 'ImportPrice'
      @ui.$importPrice.select()
    else if Session.get("productManagementUnitEditingRow").select is 'SalePrice'
      @ui.$salePrice.select()

  events:
    "keyup input[name]": (event, template) ->
      if event.which is 13
        unitOption = {}
        name    = template.ui.$unitName.val()
        barcode = template.ui.$barcode.val()
        salePrice   = Math.abs(Helpers.Number(template.ui.$salePrice.inputmask('unmaskedvalue')))
        importPrice = Math.abs(Helpers.Number(template.ui.$importPrice.inputmask('unmaskedvalue')))
        conversion  = Math.abs(Helpers.Number($conversion.inputmask('unmaskedvalue'))) if $conversion = template.ui.$conversion

        unitOption.name        = name if name isnt @name
        unitOption.barcode     = barcode if barcode isnt @barcode
        unitOption.salePrice   = salePrice if salePrice isnt @salePrice
        unitOption.importPrice = importPrice if importPrice isnt @importPrice
        unitOption.conversion  = conversion if conversion isnt @conversion and @allowDelete

        scope.currentProduct.unitUpdate(@_id, unitOption)
        Session.set("productManagementUnitEditingRow")

#    "click .changeSmallerUnit": (event, template) ->
#      if @allowDelete and Session.get('productManagementCurrentProduct')
#        Meteor.call 'changedSmallerUnit', Session.get('productManagementCurrentProduct')._id, @_id, (error, result) ->
#          if error then console.log error
#          else
#            template.ui.$importPrice.val result.importPrice
#            template.ui.$price.val result.price
#
#
#
