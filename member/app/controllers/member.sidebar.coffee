Spine   = require('spine')
Catalog = require('models/catalog')
Default = require('models/default')
$       = Spine.$

class Sidebar extends Spine.Controller
	className: 'sidebar'
    
	elements:
		'.items': 'items'
		'input': 'search'

	events:
		'click a':'action'
  
	constructor: ->
		super
		@active @change

		@default = $.Deferred()
		Default.bind "refresh",=>@default.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
     
	render: =>
		@html require('views/sidebar')(@item)
    
	change: (item) =>
		try
			$.when(@default).done =>
				@item = 
					catalog:Catalog.all()
					defaults:Default.first()
				@render()
		catch err
			@log "file: member.sidebar.coffee\nclass: Sidebar\nerror: #{err.message}"
    
	action:(e)=>
		action = $(e.target).attr "data-action"
		action = "/#{action}" if action isnt ""
		@navigate("/members#{action}")


module.exports = Sidebar