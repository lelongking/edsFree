Apps.Merchant.productGroupInit.push (scope) ->
  scope.createNewProductGroup = (template) ->
    name = Session.get("productGroupSearchFilter")
    if name?.length > 0 and Session.get("productGroupCreationMode")
      if ProductGroup.nameIsExisted(name, Session.get("myProfile").merchant)
        template.ui.$searchFilter.notify("Nhóm khách hàng đã tồn tại.", {position: "bottom"})
      else
        scope.resetSearchFilter(template) if ProductGroup.insert(name)


  scope.editProductGroup = (template) ->
    group = Session.get("currentProductGroup")
    if group and Session.get("productGroupShowEditCommand")
      $name        = template.ui.$productGroupName
      $description = template.ui.$productGroupDescription
      editOptions = {name: $name.val(), description: $description.val()}

      groupFound = Schema.productGroups.findOne({name: editOptions.name, merchant: Merchant.getId()})
      if editOptions.name.length is 0
        $name.notify("Tên khách hàng không thể để trống.", {position: "right"})
      else if groupFound and groupFound._id isnt group._id
        $name.notify("Tên khách hàng đã tồn tại.", {position: "right"})
        $name.val editOptions.name
        Session.set("productGroupShowEditCommand", false)
      else
        Schema.productGroups.update group._id, {$set: editOptions}, (error, result) -> if error then console.log error
        $name.val editOptions.name
        Session.set("productGroupShowEditCommand", false)


  scope.addProduct = ->
    Schema.products.find({}).forEach(
      (product) ->
        Schema.products.update product._id, $set: {group: "JEWNp6EntMwT8HByb"}
        Schema.productGroups.update "JEWNp6EntMwT8HByb", $addToSet: {products: product._id }
    )