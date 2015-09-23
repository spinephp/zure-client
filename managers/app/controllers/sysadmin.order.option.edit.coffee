Spine	= require('spine')

$		= Spine.$
Currents = require('controllers/sysadmin.order.current')
Receiver = require('controllers/sysadmin.order.consignee')
Payments = require('controllers/sysadmin.order.payment')
Transports = require('controllers/sysadmin.order.transport')
Bills = require('controllers/sysadmin.order.bill')
Products = require('controllers/sysadmin.order.product')

class OrderEdits extends Spine.Controller
	className: 'orderedits'
  
	constructor: ->
		super
		@active @change
	
		@currents    = new Currents
		@receiver    = new Receiver
		@payments    = new Payments
		@transports  = new Transports
		@bills       = new Bills
		@products    = new Products

		divide = $('<div class="infotitle">订单信息</div>')
	
		@append @currents,divide,@receiver,@payments,@transports,@bills,@products

	change: (params) ->
		@currents.active params
		@receiver.active params
		@payments.active params
		@transports.active params
		@bills.active params
		@products.active params

module.exports = OrderEdits