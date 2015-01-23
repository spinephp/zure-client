Spine   = require('spine')
Order = require('models/order')
Payment = require('models/payment')
$       = Spine.$

class Payments extends Spine.Controller
	className: 'payments'

	events:
		"change input":"changeEv"
  
	constructor: ->
		super
		@active @change

		@order = $.Deferred()
		@payment = $.Deferred()

		Order.bind "refresh",=>@order.resolve()
		Payment.bind "refresh",=>@payment.resolve()

	render: =>
		@html require('views/orderpayment'+@eco)(@item)
	
	change: (params) =>
		try
			$.when( @order,@payment).done =>
				if Order.exists params.id
					order = Order.find params.id
					@item = 
						orders:order
						pays:Payment.find order.paymentid
					@eco = params.match[0].substr(-4)
					@eco = 'show' if order.stateid isnt 1
					@render()
		catch err
			@log "file: sysadmin.order.payment.coffee\nclass: Payments\nerror: #{err.message}"
	
	changeEv: (e) ->
		e.stopPropagation()
		e.preventDefault()
		Spine.trigger "paymentchange",$(e.target)

module.exports =  Payments