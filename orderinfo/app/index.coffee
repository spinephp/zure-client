require('lib/setup')

Spine = require('spine')
OrderInfo = require('controllers/orderinfo')

class App extends Spine.Controller
  constructor: ->
    super
    @orderinfo = new OrderInfo
    @append @orderinfo.active()
    
    Spine.Route.setup()

module.exports = App