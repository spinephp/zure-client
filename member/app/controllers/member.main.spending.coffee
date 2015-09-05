Spine   = require('spine')

Order = require('models/order')
Currency = require('models/currency')
Default = require('models/default')
$       = Spine.$

class mySpendings extends Spine.Controller
	className: 'myspendings'

	elements:
		".tabs":'tabsEl'
		"#home-menu-2 button": 'btnCare'
  
	events:
		'click .edit': 'edit'
  
	constructor: ->
		super
		@active @change

		@order = $.Deferred()
		@currency = $.Deferred()
		@default = $.Deferred()

		Order.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText

		Order.bind "refresh",=> @order.resolve()
		Currency.bind "refresh",=> @currency.resolve()
		Default.bind "refresh",=> @default.resolve()
		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@item.currency = Currency.find @item.defaults.currencyid
				@render()

		Order.fetch()

	render: ->
		@html require("views/spending")(@item)
		$(@tabsEl).tabs()
	
	change: (params) =>
		try
			$.when(@order,@currency,@default).done( =>
				defaults = Default.first()
				@item = 
					orders:Order
					currency:Currency.find defaults.currencyid
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.spending.coffee\nclass: mySpendings\nerror: #{err.message}"
	
	edit: ->
		@navigate('/members', @item.id, 'edit')

module.exports = mySpendings