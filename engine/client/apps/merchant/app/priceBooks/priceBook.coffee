scope = logics.priceBook

lemon.defineApp Template.priceBook,
  creationMode: -> Session.get("priceBookCreationMode")
  currentPriceBook: -> Session.get("currentPriceBook")
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  activeClass:-> if Session.get("currentPriceBook")?._id is @._id then 'active' else ''

  created: ->
    PriceBookSearch.search('')

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      priceBookSearch = Helpers.Searchify searchFilter
      Session.set("priceBookSearchFilter", searchFilter)

      if event.which is 17 then console.log 'up'
      else if event.which is 38 then scope.PriceBookSearchFindPreviousPriceBook(priceBookSearch)
      else if event.which is 40 then scope.PriceBookSearchFindNextPriceBook(priceBookSearch)
      else
        scope.createNewPriceBook(template, searchFilter) if event.which is 13
        PriceBookSearch.search priceBookSearch


    "click .inner.caption": (event, template) -> PriceBook.setSession(@_id)
