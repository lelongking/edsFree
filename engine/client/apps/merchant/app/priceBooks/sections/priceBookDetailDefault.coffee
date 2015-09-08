scope = logics.priceBook

lemon.defineHyper Template.priceBookDetailDefault,
  helpers:
    isPriceBookType: (bookType)->
      priceType = Session.get("currentPriceBook").priceBookType
      return true if bookType is 'default' and priceType is 0
      return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
      return true if bookType is 'provider' and (priceType is 3 or priceType is 4)

    allProductUnits: ->
      productLists = []; priceBook = @;
      lists = Schema.products.find(
        {_id: {$in: priceBook.products} ,'priceBooks._id': priceBook._id}
        {sort: {name: 1}}
      ).fetch()

      for product in lists
        priceBook = _.findWhere(product.priceBooks, {_id: priceBook._id})
        basicUnit = _.findWhere(product.units, {isBase: true})

        if basicUnit and priceBook
          basicUnit.product         = product._id
          basicUnit.productName     = product.name
          basicUnit.productUnitName = basicUnit.name
          basicUnit.priceBookType   = priceBook.priceBookType

          basicUnit.salePrice        = priceBook.salePrice
          basicUnit.basicSalePrice   = priceBook.salePrice
          basicUnit.importPrice      = priceBook.importPrice
          basicUnit.basicImportPrice = priceBook.importPrice

          productLists.push(basicUnit)

      scope.allProductUnits = productLists
      return productLists

    productSelected: -> if _.contains(Session.get("priceProductLists"), @_id) then 'selected' else ''

  events:
    "click .detail-row:not(.selected) td.command": (event, template) -> scope.currentPriceBook.selectedPriceProduct(@_id)
    "click .detail-row.selected td.command": (event, template) -> scope.currentPriceBook.unSelectedPriceProduct(@_id)

    "dblclick .detail-row": (event, template) ->Session.set("editingId", @_id); event.stopPropagation()

