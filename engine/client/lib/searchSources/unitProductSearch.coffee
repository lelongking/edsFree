@UnitProductSearch = new SearchSource 'products', ['name'],
#  keepHistory: 1000 * 60 * 5
  localSearch: true

@UnitProductSearch.fetchData =(searchText, options, callback) ->
  selector = {status: 1}; options = {sort: {name: 1}, limit: 200}
  if(searchText)
    regExp = Helpers.BuildRegExp(searchText);
    selector = {$or: [
      {name: regExp, status: 1}
    ]}
  productLists = []
  for product in Schema.products.find(selector, options).fetch()
    quality = product.quantities[0].availableQuantity
    for unit in product.units
      unit.unitName = unit.name
      unit.name     = product.name
      unit.avatar   = product.avatar
      unit.status   = product.status
      unit.stock    = if product.inventoryInitial then Math.floor(quality/unit.conversion) else ''
      unit.inventoryInitial = product.inventoryInitial
      productLists.push(unit)

  callback(false, productLists)

Template.registerHelper 'unitProductSearches', ->
  UnitProductSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {name: 1}
