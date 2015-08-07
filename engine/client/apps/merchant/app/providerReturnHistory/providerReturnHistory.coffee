scope = logics.providerReturnHistory
Enums = Apps.Merchant.Enums

lemon.defineApp Template.providerReturnHistory,
  helpers:
    details: ->
      details = []
      returnQuery =
        merchant    : Merchant.getId()
        returnType  : Enums.getValue('ReturnTypes', 'provider')
        returnStatus: Enums.getValue('ReturnStatus', 'success')
      returns = Schema.returns.find(returnQuery, {sort:{successDate: -1}}).fetch()

      if returns.length > 0
        for key, value of _.groupBy(returns, (item) -> moment(item.successDate).format('MM/YYYY'))
          details.push({createdAt: key, data: value})
      details

  rendered: ->
  destroyed: ->

  events:
    "click .caption.inner": (event, template) ->
      Meteor.users.update(userId, {$set: {'sessions.currentProviderReturnHistory': @_id}}) if userId = Meteor.userId()

