Enums = Apps.Merchant.Enums
Meteor.methods
  createUserByEmail: (email, password)->
    profile = {
      gender    : true
      name      : email
      merchant  : Merchant.getId()
    }
    userId = Accounts.createUser {email: email, password: password, profile: profile}