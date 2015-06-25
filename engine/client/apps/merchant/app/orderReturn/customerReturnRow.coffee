scope = logics.customerReturn
lemon.defineHyper Template.customerReturnRowEdit,
  finalPrice: -> @quality * (@price - @discountCash)
#  crossReturnAvailableQuality: ->
#    returnDetail = @
#    if currentReturn = Session.get('currentCustomerReturn')
#      currentProduct = []
#      Schema.sales.find({buyer: currentReturn.customer}).forEach(
#        (sale)->
#          Schema.saleDetails.find({sale: sale._id, product: returnDetail.product}).forEach(
#            (saleDetail)-> currentProduct.push saleDetail
#          )
#      )
#      sameProducts = Schema.returnDetails.find({return: returnDetail.return, product: returnDetail.product}).fetch()
#
#      crossProductQuality = 0
#      currentProductQuality = 0
#      crossProductQuality += item.returnQuality for item in sameProducts
#      currentProductQuality += (item.quality - item.returnQuality) for item in currentProduct
#
#      crossAvailable = currentProductQuality - crossProductQuality
#      if crossAvailable < 0
#        crossAvailable = Math.ceil(Math.abs(crossAvailable/returnDetail.conversionQuality))*(-1)
#      else
#        Math.ceil(Math.abs(crossAvailable/returnDetail.conversionQuality))
#
#      return {
#        crossAvailable: crossAvailable
#        isValid: crossAvailable > 0
#        invalid: crossAvailable < 0
#        errorClass: if crossAvailable >= 0 then '' else 'errors'
#      }

  rendered: ->
    @ui.$editQuality.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$editQuality.val Template.currentData().quality

    @ui.$editQuality.select()

  events:
    "keyup": (event, template) ->
      rowId = Template.currentData()._id
      details = Template.parentData().details

      quality = Number(template.ui.$editQuality.inputmask('unmaskedvalue'))
      if quality < 0
        quality = Math.abs(quality)
        template.ui.$editQuality.val(quality)

      if event.which is 13
        discountCash = undefined if discountCash is Template.currentData().price
        quality      = undefined if quality is Template.currentData().quality
        if quality isnt undefined or discountCash isnt undefined
          scope.currentCustomerReturn.editReturnDetail(rowId, quality, discountCash)
          Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)
      else if event.which is 40  #downArrow
        Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)
      else if event.which is 38  #upArrow
        Session.set("editingId", previousRow._id) if previousRow = details.getPreviousBy("_id", rowId)

lemon.defineHyper Template.customerReturnRowDisplay,
  finalPrice: -> @quality * (@price - @discountCash)