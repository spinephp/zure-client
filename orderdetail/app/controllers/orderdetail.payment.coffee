Spine   = require('spine')
Order = require('models/order')
Payment = require('models/payment')
$       = Spine.$

class Payments extends Spine.Controller
	className: 'payments'
  
	constructor: ->
		super
		@active @change
		Order.bind('refresh change', @render)
		Payment.bind('refresh change', @render)
   
	render: =>
		try
			if Order.count() and Payment.count()
				order = Order.first()
				pay = Payment.find order.paymentid
				@html require('views/showpayment')({orders:order,pays:pay})
		catch err
			console.log err.message
	
	change: (params) =>
		@render()

module.exports =  Payments