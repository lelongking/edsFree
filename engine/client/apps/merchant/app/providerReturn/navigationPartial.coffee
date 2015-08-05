lemon.defineApp Template.providerReturnNavigationPartial,
  events:
    "click .toHistoryReturn": (event, template) -> Router.go('/importReturnHistory')