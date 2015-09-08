Enums = Apps.Merchant.Enums

@ProductSearch = new SearchSource 'products', ['name'],
  keepHistory: 1000 * 60 * 5
  localSearch: true

@ProductSearch.fetchData =(searchText, options, callback) ->
  selector = {}; options = {sort: {nameSearch: 1}}

  if(searchText)
    regExp = Helpers.BuildRegExp(searchText)
    selector = {$or: [{nameSearch: regExp}]}

  unless User.hasManagerRoles()
    if(searchText)
      selector.$or[0].status = Enums.getValue('ProductStatuses', 'confirmed')
    else
      selector.status = Enums.getValue('ProductStatuses', 'confirmed')

  callback(false, Schema.products.find(selector, options).fetch())

Template.registerHelper 'productSearches', ->
  ProductSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {nameSearch: 1}
