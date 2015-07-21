@StaffSearch = new SearchSource 'staffs', ['name'],
  keepHistory: 1000 * 60 * 5
  localSearch: true

@StaffSearch.fetchData =(searchText, options, callback) ->
  selector = {}; options = {sort: {name: 1}, limit: 20}
  if(searchText)
    regExp = Helpers.BuildRegExp(searchText);
    selector = {$or: [
      {'profile.name': regExp}
    ]}
  callback(false, Meteor.users.find(selector, options).fetch())

Template.registerHelper 'staffSearches', ->
  StaffSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {name: 1}
