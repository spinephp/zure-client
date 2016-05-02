Spine   = require('spine')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
My = require('models/my' )
$       = Spine.$
addOrderDialog = require('controllers/addOrderDialog')

class ResetPassword extends Spine.Controller
	className: 'resetpassword'
  
	constructor: ->
		super
		return if 'ResetPassword' isnt $.getUrlParam 'type'
		@active @change
		
		@my = $.Deferred()
		@currency = $.Deferred()
		@language = $.Deferred()
		@default = $.Deferred()

		My.bind "refresh",=>@my.resolve()
		Currency.bind "refresh",=>@currency.resolve()
		Language.bind "refresh",=>@language.resolve()
		Default.bind "refresh",=>@default.resolve()

		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()
	 
	render: =>
		@html require('views/resetpassword')(@item)
	
	change: (params) =>
		try
			$.when(@my,@currency,@language,@default).done =>
				if My.count() > 0
					default1 = Default.first()
					@item = 
						my:My.first()
						languages:Language.all()
						currencys:Currency.find default1.currencyid
						default: default1
					@render()
		catch err
			console.log err.message

module.exports = ResetPassword
