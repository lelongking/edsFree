scope = logics.priceBook

lemon.defineApp Template.priceBook,
  helpers:
    isPriceBookType: (bookType)->
      priceType = Session.get("currentPriceBook").priceBookType
      return true if bookType is 'default' and priceType is 0
      return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
      return true if bookType is 'provider' and (priceType is 3 or priceType is 4)

    priceBookLists: ->
      console.log 'reactive....'
      selector = {}; options  = {sort: {priceBookType: 1, name: 1}}; searchText = Session.get("priceBookSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {name: regExp}
        ]}
      priceBookFounds = Schema.priceBooks.find(selector, options).fetch()
      scope.priceBookLists = getPriceBook(priceBookFounds)
      scope.priceBookLists

  created: ->
    Session.set("priceBookSearchFilter", '')


  events:
    "click .inner.caption": (event, template) -> Session.set("editingId"); PriceBook.setSession(@_id)
    "keyup input[name='searchFilter']": (event, template) ->
      scope.searchPriceBookSearchAndCreate(event, template)

getPriceBook = (priceBookFounds) ->
  priceBookLists = []
  priceBookFounds =_.groupBy priceBookFounds, (priceBook) ->
    if priceBook.priceBookType is 0 then 'Cơ Bản'
    else if priceBook.priceBookType is 1 then 'Khách Hàng'
    else if priceBook.priceBookType is 2 then 'Khu Vực - Vùng'
    else if priceBook.priceBookType is 3 then 'Nhà Cung Cấp'
    else if priceBook.priceBookType is 4 then 'Nhóm Nhà Cung Cấp'

  priceBookLists.push {_id: key, childs: childs} for key, childs of priceBookFounds
  return priceBookLists