simpleSchema.customerGroups = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  nameSearch  : simpleSchema.searchSource('name')
  description : simpleSchema.OptionalString
  staff       : simpleSchema.OptionalString
  priceBook   : simpleSchema.OptionalString
  customers   : type: [String], defaultValue: []
  totalCash   : type: Number, defaultValue: 0

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }
  isBase      :
    type: Boolean
    autoValue: ->
      if @isInsert
        return false
      else if @isUpsert
        return { $setOnInsert: false }

      return

Schema.add 'customerGroups', "CustomerGroup", class CustomerGroup
  @transform: (doc) ->
    doc.customerCount = ->
      if @customers
        if User.hasManagerRoles()
          @customers.length
        else
          _.intersection(@customers, Meteor.users.findOne(Meteor.userId()).profile.customers).length
      else 0

    doc.reCalculateTotalCash = ->
      totalCash = 0
      Schema.customers.find({group: @_id}).forEach((customer) -> totalCash += (customer.debtCash + customer.loanCash))
      Schema.customerGroups.update @_id, $set:{totalCash: totalCash}

    doc.remove = ->
      if @allowDelete
        Schema.customerGroups.remove(@_id)
        findCustomerGroup = Schema.customerGroups.findOne({isBase: true, merchant: Merchant.getId()})
        CustomerGroup.setSessionCustomerGroup(findCustomerGroup._id) if findCustomerGroup

    doc.changeCustomerTo = (customerGroupId) ->
      if user = Meteor.users.findOne(Meteor.userId())
        customerList = []; customerSelected = user.sessions.customerSelected[@_id]
        for customerId in customerSelected
          if customerFound = Schema.customers.findOne({_id: customerId, group: @_id})
            Schema.customers.update(customerFound._id, $set: {group: customerGroupId})
            customerList.push(customerFound._id)


        updateGroupFrom = $pullAll:{customers: customerSelected}
        customerNotExistedCount = (_.difference(@customers, customerSelected)).length
        updateGroupFrom.$set = {allowDelete: true} if customerNotExistedCount is 0 and @isBase is false
        updateGroupFrom.$inc = {totalCash: -(customerFound.debtCash + customerFound.loanCash)}
        Schema.customerGroups.update @_id, updateGroupFrom

        updateGroupTo = $set:{allowDelete: false}, $addToSet:{customers: {$each: customerList}}
        updateGroupTo.$inc = {totalCash: customerFound.debtCash + customerFound.loanCash}
        Schema.customerGroups.update customerGroupId, updateGroupTo

        userUpdate = $set:{}; userUpdate.$set["sessions.customerSelected.#{@_id}"] = []
        Meteor.users.update(user._id, userUpdate)

    doc.selectedCustomer = (customerId)->
      if userId = Meteor.userId()
        userUpdate = $addToSet:{}; userUpdate.$addToSet["sessions.customerSelected.#{@_id}"] = customerId
        Meteor.users.update(userId, userUpdate)

    doc.unSelectedCustomer = (customerId)->
      if userId = Meteor.userId()
        userUpdate = $pull:{}; userUpdate.$pull["sessions.customerSelected.#{@_id}"] = customerId
        Meteor.users.update(userId, userUpdate)

  @insert: (name, description)->
    return false if !name

    newGroup = {name: name}
    newGroup.description = description if description
    newCustomerId = Schema.customerGroups.insert newGroup
    CustomerGroup.setSessionCustomerGroup(newCustomerId) if newCustomerId
    newCustomerId

  @nameIsExisted: (name, merchant = Merchant.getId()) ->
    return true if !merchant or !name
    existedQuery = {name: name, merchant: merchant}
    if Schema.customerGroups.findOne(existedQuery) then true else false

  @setSessionCustomerGroup: (customerGroupId) ->
    return false if !customerGroupId
#    Meteor.subscribe('productManagementCurrentProductData', @_id) if Meteor.isClient
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomerGroup': customerGroupId}})

  @getBasicGroup: -> Schema.customerGroups.findOne {isBase: true, merchant: Merchant.getId()}
  @addCustomer = (customerId)->
    customer = Schema.customers.findOne(customerId)
    group = Schema.customerGroups.findOne({isBase: true})
    if customer and group
      Schema.customers.update customer._id, $set: {group: group._id}
      Schema.customerGroups.update customer.group, {$pull: {customers: customer._id }, $inc:{totalCash: -customer.totalCash}} if customer.group
      Schema.customerGroups.update group._id, {$addToSet: {customers: customer._id }, $inc:{totalCash: customer.totalCash}}