Spine   = require('spine')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
My = require('models/my' )
$       = Spine.$
addOrderDialog = require('controllers/addOrderDialog')

class ResetPassword extends Spine.Controller
	className: 'resetpassword'

	elements:
		'form':'formEl'
		'input[type=password]':'passwordEl'

	events:
		'click input[type=button]':'submitReset'

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
				default1 = Default.first()
				@item = 
					languages:Language.all()
					currencys:Currency.find default1.currencyid
					default: default1
				if My.count() > 0
					my = My.first()
					if my.hash is $.getUrlParam 'verify'
						now = new Date()
						pass = new Date(Date.parse(my.lasttime))
						if (now - pass) < 48*60*60000
							@item.my = my
						else 
							@item.my = 'Link has expired'
					else 
						@item.my = "Invalid option"
				else 
					@item.my = "Invalid option"
				@render()
		catch err
			console.log err.message
	submitReset:(e)=>
		e.stopPropagation()
		key = $(@formEl).serializeArray()
		if key[0].value isnt key[1].value
			$(@passwordEl).val ''
			$(@passwordEl).eq(0).keyup()
			$(@passwordEl).eq(0).focus()
			return off

		My.bind "beforeUpdate",->
			My.url = "woo/"+My.url if My.url.indexOf('woo/') is-1
			My.url += "&token="+$.fn.cookie('PHPSESSID') unless My.url.match /token/

		My.bind "ajaxSuccess", (status, xhr) ->
			@log xhr
			@log status
			 
		@item.my.pwd = key[0].value
		@item.my.save()


module.exports = ResetPassword
