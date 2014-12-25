require('lib/setup')

Spine = require('spine')
Members    = require('controllers/member')

class App extends Spine.Controller
  constructor: ->
    super
    @member = new Members
    @append @member.active()
    
    Spine.Route.setup()

module.exports = App
