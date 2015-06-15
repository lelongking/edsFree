lemon.defineApp Template.providerManagementNavigationPartial,
  events:
    "click .providerToImport": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider")
        Meteor.call 'providerToImport', provider, Session.get('myProfile'), (error, result) ->
          if error then console.log error else Router.go('/import')

    "click .providerToReturns": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider")
        Meteor.call 'providerToReturns', provider, Session.get('myProfile'), (error, result) ->
          if error then console.log error else Router.go('/providerReturn')
