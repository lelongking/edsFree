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
  unless User.roleIsManager()
    if searchText
      selector.$or[0]._id = {$in: Session.get('myProfile').customers}
    else
      selector._id = {$in: Session.get('myProfile').customers}

  callback(false, Schema.customers.find(selector, options).fetch())

Template.registerHelper 'customerSearches', ->
  CustomerSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {name: 1}
