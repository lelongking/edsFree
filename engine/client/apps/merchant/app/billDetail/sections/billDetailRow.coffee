scope = logics.billDetail
lemon.defineHyper Template.billDetailRowEdit,
  rendered: ->
    @ui.$editQuantity.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$editDiscountCash.inputmask "integer",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11}

    @ui.$editQuantity.val Template.currentData().quality
    @ui.$editDiscountCash.val Template.currentData().discountCash

    @ui.$editQuantity.select()

  events:
    "click .deleteOrderDetail": (event, template) -> scope.currentBillHistory.removeDetail(@_id)
    "keyup": (event, template) ->
      rowId = Template.currentData()._id
      details = Template.parentData().details

      discountCash = Number(template.ui.$editDiscountCash.inputmask('unmaskedvalue'))
      if discountCash < 0
        discountCash = Math.abs(discountCash)
        template.ui.$editDiscountCash.val(discountCash)
      else if discountCash > Template.currentData().price
        discountCash = Template.currentData().price
        template.ui.$editDiscountCash.val(discountCash)

      quality = Number(template.ui.$editQuantity.inputmask('unmaskedvalue'))
      if quality < 0
        quality = Math.abs(quality)
        template.ui.$editQuantity.val(quality)


      if event.which is 13
        discountCash = undefined if discountCash is Template.currentData().price
        quality      = undefined if quality is Template.currentData().quality
        if quality isnt undefined or discountCash isnt undefined
          scope.currentBillHistory.editDetail(rowId, quality, discountCash)
          Session.set("editingId", if nextRow = details.getNextBy("_id", rowId) then nextRow._id else undefined)
#          Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)
      else if event.which is 40  #downArrow
        Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)
      else if event.which is 38  #upArrow
        Session.set("editingId", previousRow._id) if previousRow = details.getPreviousBy("_id", rowId)