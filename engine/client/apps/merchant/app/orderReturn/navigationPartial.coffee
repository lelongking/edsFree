lemon.defineApp Template.customerReturnNavigationPartial,
  events:
    "click .toHistoryReturn": (event, template) -> Router.go('/orderReturnHistory')