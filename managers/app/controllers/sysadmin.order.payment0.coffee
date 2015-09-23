Spine   = require('spine')
Order = require('models/order')
Payment = require('models/payment')
$       = Spine.$

class PaymentShow extends Spine.Controller
	className: 'paymentshow'

	constructor: ->
		super
		@active @change
   
	render: =>
		try
			if Order.count() and Payment.count() and @orderid
				order = Order.find @orderid
				pay = Payment.find order.paymentid
				@html require('views/orderpayment0')({orders:order,pays:pay})
		catch err
			@log "file: sysadmin.order.payment.coffee\nclass: Payments\nerror: #{err.message}"
	
	change: (params) =>
		@orderid = params.id
		@render()

module.exports =  PaymentShow