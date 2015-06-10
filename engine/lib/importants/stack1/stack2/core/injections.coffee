String.prototype.toCapitalize = -> @charAt(0).toUpperCase() + @slice(1)
Array.prototype.getIndexBy = (key, value) ->
  for current, i in @
    return i if current[key] is value
  return -1
Array.prototype.getNextBy     = (key, value) -> @[@getIndexBy(key, value) + 1]
Array.prototype.getPreviousBy = (key, value) -> @[@getIndexBy(key, value) - 1]