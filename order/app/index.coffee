require('lib/setup')

Spine = require('spine')
Goods    = require('controllers/good')

class App extends Spine.Controller
  constructor: ->
    super
    @good = new Goods
    @append @good.active()
    
    Spine.Route.setup()

module.exports = App
