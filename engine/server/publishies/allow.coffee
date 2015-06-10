Schema.notifications.allow
  insert: -> true
  update: -> true
  remove: -> true

#-----------------------------------------------------------------------------------------------------------------------
Schema.merchants.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.warehouses.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.skulls.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.products.allow
  insert: (userId, product) -> true
  update: (userId, product) -> true
  remove: (userId, product) -> true


#-----------------------------------------------------------------------------------------------------------------------
Schema.customers.allow
  insert: (userId, customer) ->
    customerFound = Schema.customers.findOne({currentMerchant: customer.parentMerchant, name: customer.name, description: customer.description})
    return customerFound is undefined
  update: -> true
  remove: (userId, customer) ->
    anySaleFound = Schema.sales.findOne {buyer: customer._id}
    anyCustomSaleFound = Schema.customSales.findOne {buyer: customer._id}
    anyTransactionFound = Schema.transactions.findOne {owner: customer._id}
    if anySaleFound or anyCustomSaleFound or anyTransactionFound then Schema.customers.update customer._id, $set:{allowDelete: false}
    return anySaleFound is undefined and anyTransactionFound is undefined and anyCustomSaleFound is undefined

Schema.partners.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.distributors.allow
  insert: (userId, distributor)->
    findDistributor = Schema.providers.findOne({name: distributor.name, parentMerchant: distributor.parentMerchant})
    if findDistributor then false else true
  update: (userId, distributor)-> true
  remove: (userId, distributor)->
    if distributor.allowDelete
      importFound = Schema.imports.findOne({distributor: distributor._id})
      customImportFound = Schema.customImports.findOne({seller: distributor._id})
      if importFound is undefined and customImportFound is undefined then true else false

Schema.providers.allow
  insert: (userId, provider) ->
    if Schema.providers.findOne({
      parentMerchant: provider.parentMerchant
      name: provider.name
    }) then false else true
  update: (userId, provider) -> true
  remove: (userId, provider) ->
    if provider.allowDelete
      if Schema.importDetails.findOne({provider: provider._id}) then false else true

#-----------------------------------------------------------------------------------------------------------------------
Schema.sales.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.orders.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.imports.allow
  insert: (userId, imports) -> true
  update: (userId, imports) -> true
  remove: (userId, imports) -> true

Schema.deliveries.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.returns.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.inventories.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.transactions.allow
  insert: -> true
  update: -> true
  remove: -> true




#-------------------------------------------------------------------
Schema.transactionDetails.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.saleDetails.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.customerAreas.allow
  insert: -> true
  update: -> true
  remove: (userId, customerArea)->
    if profile = Schema.userProfiles.findOne({user: Meteor.userId()})
      anyCustomerFound = Schema.customers.findOne {parentMerchant: profile.parentMerchant, areas: {$elemMatch: {$in:[customerArea._id]}}}
      return anyCustomerFound is undefined

Schema.customImports.allow
  insert: (userId, customImport) -> true
  update: (userId, customImport) -> true
  remove: (userId, customImport) -> true

Schema.branchProductUnits.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.productDetails.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.partnerSales.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.partnerSaleDetails.allow
  insert: -> true
  update: -> true
  remove: -> true
Schema.inventoryDetails.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.branchProfiles.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.merchantProfiles.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.metroSummaries.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.returnDetails.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.branchProductSummaries.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.productUnits.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.productLosts.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.expiringProducts.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.customImportDetails.allow
  insert: (userId, customImportDetail) -> true
  update: (userId, customImportDetail) -> true
  remove: (userId, customImportDetail) -> true

Schema.customSales.allow
  insert: (userId, customSale) -> true
  update: (userId, customSale) -> true
  remove: (userId, customSale) -> true

Schema.customSaleDetails.allow
  insert: (userId, customSaleDetail) -> true
  update: (userId, customSaleDetail) -> true
  remove: (userId, customSaleDetail) -> true

Schema.importDetails.allow
  insert: (userId, importDetail) -> true
  update: (userId, importDetail) -> true
  remove: (userId, importDetail) -> true

Schema.orderDetails.allow
  insert: -> true
  update: -> true
  remove: -> true