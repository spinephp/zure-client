Spine   = require('spine')
Consignee = require('models/consignee')
Payment = require('models/payment')
Transport = require('models/transport')
Bill = require('models/bill')
Billfree = require('models/billfree')
Billsale = require('models/billsale')
Billcontent = require('models/billcontent')
Order = require('models/order')
#Product   = require('models/orderproducts')
Province = require('models/province')
Orderstate = require('models/orderstate')
Thisstate = require('models/theorderstate')
$       = Spine.$

Currents = require('controllers/orderedit.current')
Process = require("controllers/orderedit.process")
Trail = require("controllers/orderedit.trail")
Receiver = require('controllers/orderedit.consignee')
Payments = require('controllers/orderedit.payment')
Transports = require('controllers/orderedit.transport')
Bills = require('controllers/orderedit.bill')
Orders = require('controllers/orderedit.product')

#Spine.Model.host = "http://127.0.0.1/woo/"

class OrderEdit extends Spine.Controller
	className: 'orderedit'
  
	constructor: ->
		super

		$.getUrlParam = (name) ->
			results = new RegExp('[\\?& ]' + name + '=([^&#]*)')
						.exec(decodeURI(window.location.href))
			return 0 if not results
			results[1] || 0
	
		@currents    = new Currents
		@process     = new Process
		@trail       = new Trail
		@receiver    = new Receiver
		@payments    = new Payments
		@transports  = new Transports
		@bills       = new Bills
		@orders      = new Orders

		Order.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		Order.fetch()
		Orderstate.fetch()
		Thisstate.fetch()
		Province.fetch()
		Consignee.fetch()
		#Product.fetch()
		Bill.fetch()
		Billfree.fetch()
		Billsale.fetch()
		Billcontent.fetch()
		Payment.fetch()
		Transport.fetch()
		
	
		status = $("<div id='tabs'><ul><li><a href='.trail' >订单跟踪</a></li><li><a href='.pay' >付款信息</a></li></ul></div>")
		divide = $('<div class="infotitle">订单信息</div>')
	
		@append @currents,@process,@trail,divide,@receiver,@payments,@transports,@bills,@orders
	
module.exports = OrderEdit