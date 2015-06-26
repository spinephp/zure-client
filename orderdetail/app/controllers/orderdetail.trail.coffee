Spine   = require('spine')
require('jqueryui-browser')
Currency = require('models/currency')
Default = require('models/default')
Orderstate = require('models/orderstate')
Thisstate = require('models/theorderstate')
$       = Spine.$

class Trails extends Spine.Controller
	className: 'trails'

	constructor: ->
		super
		@active @change
		
		@currency = $.Deferred()
		@default = $.Deferred()
		@orderstate = $.Deferred()
		@thisstatre = $.Deferred()
		Currency.bind "refresh",=>@currency.resolve()
		Default.bind "refresh",=>@default.resolve()
		Orderstate.bind "refresh",=>@orderstate.resolve()
		Thisstate.bind "refresh",=>@thisstatre.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@item.currency = Currency.find @item.default.currencyid
				@render()

	render: =>
		@html require('views/showtrail') @item
		$(@el).tabs()

	change: (item) =>
		try
			$.when(@orderstate,@thisstatre,@default,@currency).done =>
				default1 = Default.first()
				thisstate = Thisstate.findByAttribute "orderid",parseInt @orderid
				@item = 
					default:default1
					currency:Currency.find default1.currencyid
					state:Orderstate.all()
					thisstate:Thisstate
				@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Goodtitle\nerror: #{err.message}"

module.exports = Trails