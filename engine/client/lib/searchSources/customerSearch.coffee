@CustomerSearch = new SearchSource 'customers', ['name'],
  keepHistory: 1000 * 60 * 5
  localSearch: true

@CustomerSearch.fetchData =(searchText, options, callback) ->
  selector = {}; options = {sort: {nameSearch: 1}, limit: 20}
  if(searchText)
    regExp = Helpers.BuildRegExp(searchText);
    selector = {$or: [
      {nameSearch: regExp}
    ]}
  unless User.hasManagerRoles()
    if searchText
      selector.$or[0]._id = {$in: Session.get('myProfile').customers}
    else
      selector._id = {$in: Session.get('myProfile').customers}

  callback(false, Schema.customers.find(selector, options).fetch())

Template.registerHelper 'customerSearches', ->
  CustomerSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {name: 1}

@FullSearch = new SearchSource 'fullSearches', ['name'],
  keepHistory: 1000 * 60 * 5
  localSearch: true

@FullSearch.fetchData =(searchText, options, callback) ->
  searchData = {orders: [], products: [], customers: [], providers: []}
  if(searchText)
    regExp = Helpers.BuildRegExp(searchText)
    products  = Schema.products.find({$or: [{nameSearch: regExp}]}).fetch()
    customers = Schema.customers.find({$or: [{nameSearch: regExp}]}).fetch()
    providers = Schema.providers.find({$or: [{nameSearch: regExp}]}).fetch()
    orders = Schema.orders.find({$or: [{orderCode: regExp}]}).fetch()

    getSearchData = ->
      searchData.orders    = orders
      searchData.products  = products
      searchData.customers = customers
      searchData.providers = providers
      [searchData]

  callback(false, getSearchData())

Template.registerHelper 'fullSearches', ->
  FullSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {name: 1}