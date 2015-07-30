totalDecoratorTiles = 6 * 4
lemon.defineApp Template.merchantHome,
  created: ->
    console.log Session.get('myProfile')

  helpers:
    decoratorIterator: ->
      array = []
      array.push i for i in [0...totalDecoratorTiles]
      array

    showMetroBySeller: -> Session.get('myProfile')?.roles is 'seller'
    showMetroByAdmin: -> Session.get('myProfile')?.roles isnt 'seller'
    metroLockerStaff: -> if User.roleIsAdmin() then '' else ' locked'

  events:
    "click [data-app]:not(.locked)": (event, template) -> Router.go $(event.currentTarget).attr('data-app')
    "click .caption.inner": -> Router.go @app