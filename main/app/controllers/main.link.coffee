Spine   = require('spine')
Link = require('models/link')
Default = require('models/default')
$       = Spine.$

class Links extends Spine.Controller
	className: 'links'

	constructor: ->
		super
		@active @change
		
		@link = $.Deferred()
		@default = $.Deferred()
		Link.bind "refresh",=>@link.resolve()
		Default.bind "refresh",=>@default.resolve() if Default.count() > 0
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
		
	render: =>
		@html require('views/link')(@item)

	change: (item) =>
		try
			$.when(@link,@default).done =>
				@item = 
					links:Link.all()
					default:Default.first()
				@render()
		catch err
			console.log err.message

module.exports = Links