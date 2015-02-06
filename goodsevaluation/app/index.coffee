require('lib/setup')

Spine = require('spine')
Goodsevaluation    = require('controllers/main')

class App extends Spine.Controller
  constructor: ->
    super
    @goodsevaluation = new Goodsevaluation
    @append @goodsevaluation.active()
    
    Spine.Route.setup()

module.exports = App
