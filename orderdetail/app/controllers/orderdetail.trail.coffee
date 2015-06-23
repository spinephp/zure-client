Spine   = require('spine')
require('jqueryui-browser')
#cdCurrency = require('models/currency')
Default = require('models/default')
Orderstate = require('models/orderstate')
Thisstate = require('models/theorderstate')
$       = Spine.$

class Trail extends Spine.Controller
	className: 'trail'

	constructor: ->
		super
		@active @change
		
		@currency = $.Deferred()
		@default = $.Deferred()
		@orderstate = $.Deferred()
		@thisstatre = $.Deferred()
		#Currency.bind "refresh",=>@currency.resolve()
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
		Spine.trigger "trail.before.render",@

	change: (item) =>
		try
			$.when(@orderstate,@thisstatre,@default).done =>
				default1 = Default.first()
				thisstate = Thisstate.findByAttribute "orderid",parseInt @orderid
				@item = 
					default:default1
					state:Orderstate.all()
					thisstate:Thisstate
				console.log @item
				@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Goodtitle\nerror: #{err.message}"

class Pay extends Spine.Controller
	className: 'pay'

	constructor: ->
		super
		@active @change

		#Thisstate.bind('refresh change', @render)

	render: =>
		try
			items = Thisstate.findByAttribute "orderid",$.getUrlParam "orderid"
			@html require('views/showpay')(state:items)
		catch err
			console.log "file: orderdetail.trail.coffee, error: #{err.message}"

	change: (item) =>
		Spine.trigger "trail.before.render"
		@render()

class Trails extends Spine.Stack
	className: 'trails stack'

	constructor: ->
		super

		Spine.bind "trail.before.render",(that)->
			$(that.$el[0]).parent().prepend "<ul><li><a href='.trail' >订单跟踪</a></li><li><a href='.pay' >付款信息</a></li></ul>"
			$(that.$el[0]).parent().tabs()
			console.log $(that.$el[0]).parent()


	controllers:
		pay: Pay
		trail: Trail

module.exports = Trails