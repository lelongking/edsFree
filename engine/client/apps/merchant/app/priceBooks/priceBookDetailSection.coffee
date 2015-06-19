scope = logics.priceBook

lemon.defineHyper Template.priceBookDetailSection,
  isPriceBookType: (bookType)->
    priceType = Session.get("currentPriceBook").priceBookType
    return true if bookType is 'default' and priceType is 0
    return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
    return true if bookType is 'provider' and (priceType is 3 or priceType is 4)

  isRowEditing: -> Session.get("editingId") is @_id
  allProductUnits: ->
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
              if item.priceBook is priceBookGroup._id
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
              if item.priceBook is priceBookGroup._id
                importPriceTemp = item.importPrice
                break

          unit.importPrice = importPriceTemp if importPriceTemp isnt undefined

        console.log unit
        productLists.push(unit)

    scope.allProductUnits = productLists
    return productLists

  rendered: ->

  events:
    "click .detail-row": (event, template) ->Session.set("editingId", @_id); event.stopPropagation()

