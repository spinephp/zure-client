require('lib/setup')

Spine = require('spine')

OrderDetail = require('controllers/orderdetail')

class App extends Spine.Controller
  constructor: ->
    super
    @orderdetail = new OrderDetail
    @append @orderdetail.active()
    
    Spine.Route.setup()

module.exports = App