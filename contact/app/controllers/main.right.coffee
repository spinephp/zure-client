Spine   = require('spine')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
$       = Spine.$
addOrderDialog = require('controllers/addOrderDialog')

class Right extends Spine.Controller
	className: 'rights'
  
	constructor: ->
		super
		@active @change
		
		@currency = $.Deferred()
		@language = $.Deferred()
		@default = $.Deferred()

		Currency.bind "refresh",=>@currency.resolve()
		Language.bind "refresh",=>@language.resolve()
		Default.bind "refresh",=>@default.resolve()

		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()
	 
	render: =>
		@html require('views/right')(@item)
	
	change: (params) =>
		try
			$.when(@currency,@language,@default).done =>
				default1 = Default.first()
				@item = 
					default: default1
				@render()
		catch err
			console.log err.message

module.exports = Right