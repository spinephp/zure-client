Spine   = require('spine')
Default = require('models/default')
Order = require('models/order')
Payment = require('models/payment')
$       = Spine.$

class Payments extends Spine.Controller
	className: 'payments'
  
	constructor: ->
		super
		@active @change
		
		@default = $.Deferred()
		@order= $.Deferred()
		@payment = $.Deferred()
		Default.bind "refresh",=>@default.resolve()
		Order.bind "refresh",=>@order.resolve()
		Payment.bind "refresh",=>@payment.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
   
	render: =>
		@html require('views/showpayment') @item
	
	change: (params) =>
		try
			$.when(@order,@payment,@default).done =>
				default1 = Default.first()
				theOrder = Order.find $.fn.getUrlParam "orderid"
				payment = Payment.find theOrder.transportid
				@item = 
					default:default1
					orders:theOrder
					pays:payment
				@render()
		catch err
			@log "file:ordertetail.product.coffee\nclass:Products\nerror: #{err.message}"

module.exports =  Payments