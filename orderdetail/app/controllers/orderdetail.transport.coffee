Spine   = require('spine')
Order = require('models/order')
Transport = require('models/transport')
$       = Spine.$

class Transports extends Spine.Controller
	className: 'transports'
  
	constructor: ->
		super
		@active @change
		Order.bind('refresh change', @render)
		Transport.bind('refresh change', @render)
   
	render: =>
		try
			if Order.count() and Transport.count()
				order = Order.first()
				transport = Transport.find order.transportid
				@html require('views/showtransport')({orders:order,transports:transport})
		catch err
			console.log err.message
    
	change: (params) =>
		@render()
    
module.exports =  Transports