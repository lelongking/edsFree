@ProductSaleSearch = new SearchSource 'products', ['name'],
  keepHistory: 1000 * 60 * 5
  localSearch: true

@ProductSaleSearch.fetchData =(searchText, options, callback) ->
  selector = {}; options = {sort: {name: 1}, limit: 20}
  if(searchText)
    regExp = Helpers.BuildRegExp(searchText);
    selector = {$or: [
      {name: regExp}
    ]}
  productLists = []
  for product in Schema.products.find(selector, options).fetch()
    for unit in product.units
      unit.unitName = unit.name
      unit.name     = product.name
      unit.avatar   = product.avatar
      productLists.push(unit)

  callback(false, productLists)

Template.registerHelper 'productSaleSearches', ->
  ProductSaleSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {name: 1}
