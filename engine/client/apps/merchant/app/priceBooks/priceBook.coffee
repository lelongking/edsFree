scope = logics.priceBook

lemon.defineApp Template.priceBook,
  created: ->
    PriceBookSearch.search('')

  events:
    "click .inner.caption": (event, template) -> Session.set("editingId"); PriceBook.setSession(@_id)
    "keyup input[name='searchFilter']": (event, template) -> scope.searchPriceBookSearchAndCreate(event, template)
