Spine	= require('spine')
Order = require('models/order')
Consignee = require('models/consignee')
Province = require('models/province')

$		= Spine.$
Currents0 = require('controllers/sysadmin.order.current0')
Receiver = require('controllers/sysadmin.order.consignee')
Payments0 = require('controllers/sysadmin.order.payment0')
Transports0 = require('controllers/sysadmin.order.transport0')
Bills = require('controllers/sysadmin.order.bill')
Products0 = require('controllers/sysadmin.order.product0')

class OrderShows extends Spine.Controller
	className: 'ordershows'
  
	constructor: ->
		super
		@active @change
	
		@currents    = new Currents0
		@receiver    = new Receiver
		@payments    = new Payments0
		@transports  = new Transports0
		@bills       = new Bills
		@products      = new Products0

		Consignee.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText
		divide = $('<div class="infotitle">订单信息</div>')
	
		@append @currents,divide,@receiver,@payments,@transports,@bills,@products

	change: (params) ->
		@currents.active params
		@receiver.active params
		@payments.active params
		@transports.active params
		@bills.active params
		@products.active params

	buildParams: (keyid,fields) ->
		ids = []
		i = 0
		ids[i++] = order[keyid] for order in Order.all() when order[keyid] not in ids
		condition = [{field:"id",value:ids,operator:"in"}]
		params =
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true

module.exports = OrderShows