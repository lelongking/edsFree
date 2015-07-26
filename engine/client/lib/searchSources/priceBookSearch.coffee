@PriceBookSearch = new SearchSource 'priceBooks', ['name'],
  keepHistory: 1000 * 60 * 5
  localSearch: true

@PriceBookSearch.fetchData =(searchText, options, callback) ->
  selector = {}; options = sort: {priceBookType: 1, name: 1}
  if(searchText)
    regExp = Helpers.BuildRegExp(searchText);
    selector = {$or: [
      {name: regExp}
    ]}

  priceBookFounds = Schema.priceBooks.find(selector, options).fetch()
  callback(false, getPriceBook(priceBookFounds))

Template.registerHelper 'priceBookSearches', ->
  PriceBookSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {priceBookType: 1, name: 1}

getPriceBook = (priceBookFounds) ->
  priceBookLists = []
  priceBookFounds =_.groupBy priceBookFounds, (priceBook) ->
    if priceBook.priceBookType is 0 then 'Cơ Bản'
    else if priceBook.priceBookType is 1 then 'Khách Hàng'
    else if priceBook.priceBookType is 2 then 'Vùng'
    else if priceBook.priceBookType is 3 then 'Nhà Cung Cấp'
    else if priceBook.priceBookType is 4 then 'Nhóm Nhà Cung Cấp'

  priceBookLists.push {_id: key, childs: childs} for key, childs of priceBookFounds
  return priceBookLists