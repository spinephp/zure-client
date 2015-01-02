require('lib/setup')

Spine = require('spine')
Mains    = require('controllers/main')

class App extends Spine.Controller
  constructor: ->
    super
    @main = new Mains
    @append @main.active()
    
    Spine.Route.setup()

module.exports = App
