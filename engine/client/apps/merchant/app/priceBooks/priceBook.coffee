scope = logics.priceBook

lemon.defineApp Template.priceBook,
  isPriceBookType: (bookType)->
    return true if Session.get("currentPriceBook").priceBookType is 0 and bookType is 'default'
    return true if Session.get("currentPriceBook").priceBookType is 1 and bookType is 'customer'
    return true if Session.get("currentPriceBook").priceBookType is 2 and bookType is 'provider'

  created: ->
    PriceBookSearch.search('')

  events:
    "click .inner.caption": (event, template) -> PriceBook.setSession(@_id)
    "keyup input[name='searchFilter']": (event, template) -> scope.searchPriceBookSearchAndCreate(event, template)
