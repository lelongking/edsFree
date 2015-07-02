scope = logics.priceBook

lemon.defineHyper Template.priceBookDetailCustomer,
  isGroup: -> Session.get("currentPriceBook").priceBookType is 2

  allProductUnits: ->
    productLists = []; priceBook = Session.get("currentPriceBook")
    for product in Schema.products.find({'units.priceBooks.priceBook': priceBook._id}, {sort: {name: 1}}).fetch()
      for unit in product.units
        for item in unit.priceBooks
          unit.productName     = product.name
          unit.productUnitName = unit.name
          unit.priceBookType   = priceBook.priceBookType
          unit.conversion      = unit.conversion

          if item.priceBook is Session.get('currentPriceBook')._id
            unit.basicSale           = item.basicSale
            unit.salePrice           = item.salePrice
            unit.discountSalePrice   = item.discountSalePrice
            unit.updateSalePriceAt   = item.updateSalePriceAt

            unit.basicImport         = item.basicImport
            unit.importPrice         = item.importPrice
            unit.discountImportPrice = item.discountImportPrice
            unit.updateImportPriceAt = item.updateImportPriceAt

            productLists.push(unit)
            break

    scope.allProductUnits = productLists
    return productLists

  allProductUnits01: ->
    productLists = []; priceBook = Session.get("currentPriceBook")
    for product in Schema.products.find({}, {sort: {name: 1}}).fetch()
      for unit in product.units
        unit.productName     = product.name
        unit.productUnitName = unit.name
        unit.priceBookType   = priceBook.priceBookType

        for item in unit.priceBooks
          if item.priceBook is Session.get('priceBookBasic')._id
            unit.salePrice   = item.salePrice
            unit.importPrice = item.importPrice
            break

        if priceBook.priceBookType is 1 or priceBook.priceBookType is 2
          unit.salePriceBasic = unit.salePrice
          salePriceTemp = undefined
          for item in unit.priceBooks
            if priceBook._id is item.priceBook
              salePriceTemp = item.salePrice
              break
          if salePriceTemp is undefined
            if priceBook.priceBookType is 1 and priceBook.owners?[0]
              priceBookGroup = Schema.priceBooks.findOne({
                productUnits  : unit._id
                owners        : priceBook.owners[0]
                priceBookType : 2
                merchant      : Session.get('merchant')._id})
              if priceBookGroup and item.priceBook is priceBookGroup._id
                salePriceTemp   = item.salePrice
                break
          unit.salePrice = salePriceTemp if salePriceTemp isnt undefined
        else if priceBook.priceBookType is 3 or priceBook.priceBookType is 4
          unit.importPriceBasic = unit.importPrice
          importPriceTemp = undefined
          for item in unit.priceBooks
            if priceBook._id is item.priceBook
              console.log item.importPrice
              importPriceTemp = item.importPrice
              break
          if importPriceTemp is undefined and priceBook.owners?[0]
            if priceBook.priceBookType is 1 and priceBook.owners?[0]
              priceBookGroup = Schema.priceBooks.findOne({
                productUnits  : unit._id
                owners        : priceBook.owners[0]
                priceBookType : 4
                merchant      : Session.get('merchant')._id})
              if priceBookGroup and item.priceBook is priceBookGroup._id
                importPriceTemp = item.importPrice
                break
          unit.importPrice = importPriceTemp if importPriceTemp isnt undefined

        productLists.push(unit)

    scope.allProductUnits = productLists
    return productLists

  productSelected: -> if _.contains(Session.get("priceProductLists"), @_id) then 'selected' else ''
  rendered: ->

  events:
    "click .detail-row:not(.selected) td.command": (event, template) -> scope.currentPriceBook.selectedPriceProduct(@_id)
    "click .detail-row.selected td.command": (event, template) -> scope.currentPriceBook.unSelectedPriceProduct(@_id)
    "click .deleteUnitPrice": (event, template) -> scope.currentPriceBook.deleteUnitPrice(@_id); Session.set("editingId")
    "dblclick .detail-row": (event, template) -> Session.set("editingId", @_id); event.stopPropagation()

