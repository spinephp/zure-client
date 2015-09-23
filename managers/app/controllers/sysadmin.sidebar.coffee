Spine   = require('spine')
Catalog = require('models/catalog')
$       = Spine.$

class Sidebar extends Spine.Controller
	className: 'sidebar'
    
	elements:
		'.items': 'items'
		'input': 'search'
    
	events:
		'click dl dd': 'action'
  
	constructor: ->
		super
		@active @render
     
	render: =>
		@html require('views/sidebar')(Catalog.all())
    
	change: (item) =>
		@render
    
	action:(e)=>
		action = $(e.target).attr "action-data"
		action = "/#{action}" if action isnt ""
		@navigate("/sysadmins#{action}")


module.exports = Sidebar