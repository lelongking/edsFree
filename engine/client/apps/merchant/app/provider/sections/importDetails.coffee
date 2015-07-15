lemon.defineWidget Template.providerManagementImportDetails,
#  created: ->
#    console.log @
#    @child = Schema.transactions.findOne({parent: @data._id})
#
#  helpers:
#    transaction: -> Template.instance().child
#    detailsTotalCash: -> cash = 0; (cash += item.quality * item.price) for item in @details; cash

#    totalDebtBalance: -> @latestDebtBalance + Session.get("providerManagementCurrentProvider")?.customImportDebt
#
#    receivableClass: -> if @debtBalanceChange >= 0 then 'paid' else 'receive'
#    finalReceivableClass: ->
#      latestDebtBalance = @latestDebtBalance + Session.get("providerManagementCurrentProvider")?.customImportDebt
#      if latestDebtBalance >= 0 then 'receive' else 'paid'


#    showDeleteImport: ->
#      if @creator is Session.get('myProfile').user
#        year = @version.createdAt.getFullYear(); mount = @version.createdAt.getMonth(); date = @version.createdAt.getDate()
#        hour = @version.createdAt.getHours(); minute = @version.createdAt.getMinutes(); second = @version.createdAt.getSeconds()
#        if checkDay = new Date(year, mount, date + 1, hour, minute, second) > new Date()
#          checkReturn = if Schema.returns.findOne({timeLineImport: @_id}) then false else true
#          checkSale = true; Schema.productDetails.find({import: @_id}).forEach(
#            (productDetail) -> checkSale = false if productDetail.importQuality isnt productDetail.availableQuality
#          )
#        checkDay and checkReturn and checkSale
#
#    showDeleteTransaction: ->
#      year = @debtDate.getFullYear(); mount = @debtDate.getMonth(); date = @debtDate.getDate()
#      hour = @debtDate.getHours(); minute = @debtDate.getMinutes(); second = @debtDate.getSeconds()
#      new Date(year, mount, date + 1, hour, minute, second) > new Date()

#    dependsData: ->
#      transactions = Schema.transactions.find({latestImport: @_id}).fetch()
#      returns = Schema.returns.find({timeLineImport: @_id}).fetch()
#      _.sortBy transactions.concat(returns), (item) -> item.version.createdAt
#
#    returnDetails: -> Schema.returnDetails.find({return: @_id})

  events:
    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id

#    "click .deleteImport": (event, template) ->
#      Meteor.call 'providerManagementDeleteImport', @_id
#      Meteor.call 'reCalculateMetroSummaryTotalPayableCash'
#      Meteor.call 'reCalculateMetroSummary'
#
#    "click .deleteTransaction": (event, template) ->
#      Meteor.call 'providerManagementDeleteTransaction', @_id
#      Meteor.call 'reCalculateMetroSummaryTotalPayableCash'
#      Meteor.call 'reCalculateMetroSummary'
