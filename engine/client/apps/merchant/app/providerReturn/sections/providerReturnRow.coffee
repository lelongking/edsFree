scope = logics.providerReturn
lemon.defineHyper Template.providerReturnRowEdit,
  rendered: ->
    @ui.$editQuantity.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$editQuantity.val Template.currentData().quality

    @ui.$editQuantity.select()

  events:
    "keyup": (event, template) ->
      rowId = Template.currentData()._id
      details = Template.parentData().details

      quality = Number(template.ui.$editQuantity.inputmask('unmaskedvalue'))
      if quality < 0
        quality = Math.abs(quality)
        template.ui.$editQuantity.val(quality)

      if event.which is 13
        discountCash = undefined if discountCash is Template.currentData().price
        quality      = undefined if quality is Template.currentData().quality

        if quality isnt undefined or discountCash isnt undefined
          scope.currentProviderReturn.editReturnDetail(rowId, quality, discountCash)

        nextRow = details.getNextBy("_id", rowId)
        Session.set("editingId", if nextRow then nextRow._id else undefined)

      else if event.which is 40  #downArrow
        Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)

      else if event.which is 38  #upArrow
        Session.set("editingId", previousRow._id) if previousRow = details.getPreviousBy("_id", rowId)

#lemon.defineHyper Template.providerReturnRowDisplay,
#  helpers:
#    crossReturnAvailableQuantity: ->
#      currentDetail = @; currentProductQuantity = 0
#      currentParent = Session.get('currentReturnParent')
#      if currentDetail and currentParent
#        for importDetail in currentParent
#          if importDetail.productUnit is currentDetail.productUnit
#            currentProductQuantity += importDetail.basicQuantity
#
#            if importDetail.returnDetails?.length > 0
#              (currentProductQuantity -= currentDetail.basicQuantity) for currentDetail in importDetail.returnDetails
#
#        crossAvailable = currentProductQuantity - currentDetail.basicQuantity
#        if crossAvailable < 0
#          crossAvailable = Math.ceil(Math.abs(crossAvailable/currentDetail.conversion))*(-1)
#        else
#          Math.ceil(Math.abs(crossAvailable/currentDetail.conversion))
#
#        return {
#          crossAvailable: crossAvailable
#          isValid: crossAvailable > 0
#          invalid: crossAvailable < 0
#          errorClass: if crossAvailable >= 0 then '' else 'errors'
#        }