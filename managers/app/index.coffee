require('lib/setup')

Spine = require('spine')
Sysadmins    = require('controllers/sysadmin')

class App extends Spine.Controller
  constructor: ->
    super
    @sysadmin = new Sysadmins
    @append @sysadmin.active()
    
    Spine.Route.setup()

module.exports = App
