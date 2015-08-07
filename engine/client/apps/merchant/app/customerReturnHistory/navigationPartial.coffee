lemon.defineApp Template.customerReturnHistoryNavigationPartial,
  events:
    "click .toCustomerReturn": (event, template) -> Router.go('/customerReturn')