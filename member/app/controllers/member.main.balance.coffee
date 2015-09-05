Spine   = require('spine')

Custom = require('models/custom')
Customaccount = require('models/customaccount')
Currency = require('models/currency')
Default = require('models/default')
$       = Spine.$

class myBalances extends Spine.Controller
	className: 'mybalances'

	elements:
		".tabs":'tabsEl'
		"#home-menu-2 button": 'btnCare'
  
	events:
		'click .edit': 'edit'
  
	constructor: ->
		super
		@active @change

		@custom = $.Deferred()
		@account = $.Deferred()
		@currency = $.Deferred()
		@default = $.Deferred()

		Custom.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText

		Custom.bind "refresh",=> @custom.resolve()
		Customaccount.bind "refresh",=> @account.resolve()
		Currency.bind "refresh",=> @currency.resolve()
		Default.bind "refresh",=> @default.resolve()
		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@item.currency = Currency.find @item.defaults.currencyid
				@render()

		Custom.fetch()
		Customaccount.fetch()

	render: ->
		@html require("views/balance")(@item)
		$(@tabsEl).tabs()
	
	change: (params) =>
		try

			$.when(@custom,@account,@currency,@default).done( =>
				defaults = Default.first()
				@item = 
					customs:Custom.first()
					accounts:Customaccount.all()
					currency:Currency.find defaults.currencyid
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.balance.coffee\nclass: myBalances\nerror: #{err.message}"
	
	edit: ->
		@navigate('/members', @item.id, 'edit')

module.exports = myBalances