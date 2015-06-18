scope = logics.priceBook

lemon.defineHyper Template.priceBookDetailSectionDefault,
  unitDetail: ->
    product = Schema.products.findOne({'units._id': @productUnit})
    productUnit = _.findWhere(product.units, {_id: @productUnit})
    productUnit.productName = product.name
    return productUnit

  rendered: ->
#    @ui.$debtDate.inputmask("dd/mm/yyyy")
#    @ui.$payAmount.inputmask("numeric",   {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11})
#    @ui.$paidDate.inputmask("dd/mm/yyyy")
#
#    @ui.$paySaleAmount.inputmask("numeric",   {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11})

#  events:

