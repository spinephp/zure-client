Spine   = require('spine')
Good = require('models/good')
Goodclass = require('models/goodclass')
Default = require('models/default')
$       = Spine.$

class Goods extends Spine.Controller
	className: 'goods'

	constructor: ->
		super
		@active @change
		
		@good = $.Deferred()
		@goodclass = $.Deferred()
		@default = $.Deferred()
		Good.bind "refresh",=>@good.resolve()
		Goodclass.bind "refresh",=>@goodclass.resolve()
		Default.bind "refresh",=>@default.resolve() if Default.count() > 0
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
		
	render: =>
		@html require('views/good')(@item)

	change: (item) =>
		try
			$.when(@good,@goodclass,@default).done =>
				@item = 
					goods:Good.all()
					default:Default.first()
				@render()
		catch err
			console.log err.message

module.exports = Goods