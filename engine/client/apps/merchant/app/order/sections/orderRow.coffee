
lemon.defineHyper Template.orderRowEdit,
  ui:
    $price: ".price input"
    $quality: ".quality input"

  detailFinalPrice: -> @quality * @price - @discountCash

  rendered: ->
    @ui.$editQuality.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11}
    @ui.$editPrice.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11}
    @ui.$editDiscountCash.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11}

    @ui.$editQuality.val Template.currentData().quality
    @ui.$editPrice.val Template.currentData().price
    @ui.$editDiscountCash.val Template.currentData().discountCash

    @ui.$editQuality.select()

#  events:
#    "keyup": (event, template) ->
#      rowId = Template.currentData()._id
#      details = Template.parentData().instance.details
#
#      if event.which is 13
#        price = accounting.parse(template.ui.$price.val())
#        quality = accounting.parse(template.ui.$quality.val())
#        Template.parentData().instance.editDetail(rowId, quality, price)
#        Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)
#      else if event.which is 40  #downArrow
#        Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)
#      else if event.which is 38  #upArrow
#        Session.set("editingId", previousRow._id) if previousRow = details.getPreviousBy("_id", rowId)
