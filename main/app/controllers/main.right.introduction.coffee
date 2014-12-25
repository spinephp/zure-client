Spine   = require('spine')
Qiye = require('models/qiye')
Default = require('models/default')
$       = Spine.$

class Introductions extends Spine.Controller
	className: 'introductions'

	constructor: ->
		super
		@active @change
		
		@qiye = $.Deferred()
		@default = $.Deferred()
		Default.bind "refresh change",=>@default.resolve() if Default.count() > 0
		Qiye.bind "refresh",=>@qiye.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
		
	render: =>
		@html require('views/qiye')(@item)

	change: (item) =>
		try
			$.when(@qiye,@default).done =>
				if Qiye.count() > 0
					@item = 
						qiye:Qiye.first()
						default:Default.first()
					@render()
		catch err
			console.log err.message

module.exports = Introductions