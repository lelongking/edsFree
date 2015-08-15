lemon.defineApp Template.warehouseNavigationPartial,
  events:
    "click .warehouseShowTradeProducts": (event, template) -> Session.set('warehouseShowAll', false)
    "click .warehouseShowAllProducts": (event, template) -> Session.set('warehouseShowAll', true)


