Spine   = require('spine')
Order = require('models/order')
Transport = require('models/transport')
$       = Spine.$

class TransportShow extends Spine.Controller
	className: 'transportshow'
  
	constructor: ->
		super
		@active @change
		Order.bind('refresh change', @render)
		Transport.bind('refresh change', @render)
   
	render: =>
		try
			if Order.count() and Transport.count() and @order
				transport = Transport.find @order.transportid
				@html require('views/ordertransport0')({orders:@order,transports:transport})
		catch err
			@log "file: sysadmin.order.transport.coffee\nclass: Transports\nerror: #{err.message}"
	
	change: (params) =>
		@order = Order.find params.id
		@render()

module.exports =  TransportShow