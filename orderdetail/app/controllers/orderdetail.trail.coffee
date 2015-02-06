Spine   = require('spine')
require('jqueryui-browser')
Orderstate = require('models/orderstate')
Thisstate = require('models/theorderstate')
$       = Spine.$

class Trail extends Spine.Controller
	className: 'trail'

	constructor: ->
		super
		@active @change

		Thisstate.bind('refresh change', @render)

	render: =>
		try
			if Thisstate.count() and Orderstate.count()
				@html require('views/showtrail')({state:Orderstate.all()})
		catch err
			console.log err.message

	change: (item) =>
		Spine.trigger "trail.before.render",@
		@render()

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
			#$(that.$el[0]).parent().tabs()
			console.log $(that.$el[0]).parent()


	controllers:
		pay: Pay
		trail: Trail

module.exports = Trails