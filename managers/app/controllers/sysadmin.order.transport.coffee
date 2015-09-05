Spine   = require('spine')
Order = require('models/order')
Transport = require('models/transport')
$       = Spine.$

class Transports extends Spine.Controller
	className: 'transports'

	events:
		"change input":"carriagechargechange"
  
	constructor: ->
		super
		@active @change

		@order = $.Deferred()
		@transport = $.Deferred()

		Order.bind "refresh",=>@order.resolve()
		Transport.bind "refresh",=>@transport.resolve()
   
	render: =>
		@html require('views/ordertransport'+@eco)(@item)
	
	change: (params) =>
		try
			$.when( @order,@transport).done =>
				if Order.exists params.id
					order = Order.find params.id
					@item = 
						orders:order
						transports:Transport.find order.transportid
					@eco = params.match[0].substr(-4)
					@eco = 'show' if order.stateid isnt 1
					@render()
		catch err
			@log "file: sysadmin.order.payment.coffee\nclass: Payments\nerror: #{err.message}"
	
	carriagechargechange: (e) =>
		e.stopPropagation()
		@item.orders.carriagecharge = e.target.value
		Spine.trigger "transportchange",e.target.value

module.exports =  Transports