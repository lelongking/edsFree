Meteor.methods
  importSubmitted: (importId)->
    userProfile = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !userProfile

    importFound = Schema.imports.findOne({_id: importId, 'profiles.importType': 0})
    return {valid: false, error: 'import not found!'} if !importFound

    for detail in importFound.details
      detailIndex = 0; updateQuery = {$inc:{}}
      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"]= detail.availableQuality
      updateQuery.$inc["qualities.#{detailIndex}.inStockQuality"]  = detail.inStockQuality
      updateQuery.$inc["qualities.#{detailIndex}.importQuality"]   = detail.importQuality
      Schema.products.update detail.product, updateQuery
    Schema.imports.update importId, {$set:{'profiles.importType': 1}}