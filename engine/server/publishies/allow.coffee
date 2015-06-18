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
  insert: -> true
  update: -> true
  remove: -> true


Schema.priceBooks.allow
  insert: -> true
  update: -> true
  remove: -> true


#-----------------------------------------------------------------------------------------------------------------------
Schema.customers.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.partners.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.distributors.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.providers.allow
  insert: -> true
  update: -> true
  remove: -> true

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
  insert: -> true
  update: -> true
  remove: -> true

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