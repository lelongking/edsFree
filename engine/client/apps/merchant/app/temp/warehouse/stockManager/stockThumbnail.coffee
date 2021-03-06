lemon.defineWidget Template.stockThumbnail,
  allowDelete: -> @totalQuantity == 0
  avatarUrl: -> undefined
  meterStyle: ->
    stockPercentage = @availableQuantity / (@normsQuantity ? 100)
    return {
      percent: stockPercentage * 100
      color: Helpers.ColorBetween(255, 0, 0, 135, 196, 57, stockPercentage, 3)
    }
  events:
    "click .full-desc.trash": ->
      if deletingProduct = Schema.products.findOne(@_id) then Schema.products.remove(deletingProduct._id)