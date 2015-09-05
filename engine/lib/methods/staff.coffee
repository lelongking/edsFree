Enums = Apps.Merchant.Enums
Meteor.methods
  createUserByEmail: (email, password)->
    profile = {
      gender    : true
      name      : email
      merchant  : Merchant.getId()
      roles     : Enums.getObject('PermissionType').seller.value
    }
    userId = Accounts.createUser {email: email, password: password, profile: profile}