#SearchSource.defineSource 'products', (searchText, options) ->
#  options = {sort: {isoScore: -1}, limit: 20}
##  predicate = if searchText then {$text: {$search:searchText, $language: 'en'}} else {}
##  Document.Product.find(predicate, options).fetch()
#  if searchText
#    regExp = buildRegExp(searchText)
#    return Schema.products.find({name: regExp}, options).fetch()
#  else
#    return Schema.products.find({}, options).fetch()
#
#buildRegExp = (searchText) ->
#  parts = searchText.trim().split(/[ \-\:]+/);
#  return new RegExp("(" + parts.join('|') + ")", "ig");