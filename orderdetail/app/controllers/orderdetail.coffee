Spine   = require('spine')
Header = require('models/header')
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
Manager = require('spine/lib/manager')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Currents = require('controllers/orderdetail.current')
Process = require("controllers/orderdetail.process")
Trail = require("controllers/orderdetail.trail")
Receiver = require('controllers/orderdetail.consignee')
Payments = require('controllers/orderdetail.payment')
Transports = require('controllers/orderdetail.transport')
Bills = require('controllers/orderdetail.bill')
Orders = require('controllers/orderdetail.product')

#Spine.Model.host = "http://127.0.0.1/woo/"

class OrderDetail extends Spine.Controller
	className: 'orderdetail'
  
	constructor: ->
		super

		$.getUrlParam = (name) ->
			results = new RegExp('[\\?& ]' + name + '=([^&#]*)')
						.exec(decodeURI(window.location.href))
			return 0 if not results
			results[1] || 0
	
		@headers     = new Headers
		@footers     = new Footers
		@currents    = new Currents
		@process     = new Process
		@trail       = new Trail
		@receiver    = new Receiver
		@payments    = new Payments
		@transports  = new Transports
		@bills       = new Bills
		@orders      = new Orders
		
		@routes
			'!/orderdetail/pay': (params) -> 
				@headers.active(params)
				@currents.active(params)
				@process.active(params)
				@trail.pay.active(params)
				@receiver.active(params)
				@payments.active(params)
				@transports.active(params)
				@bills.active(params)
				@orders.active(params)
				@footers.active(params)
			'!/orderdetail': (params) ->
				@headers.active(params)
				@currents.active(params)
				@process.active(params)
				@trail.trail.active(params)
				@receiver.active(params)
				@payments.active(params)
				@transports.active(params)
				@bills.active(params)
				@orders.active(params)
				@footers.active(params)
		

		Order.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		Header.fetch()
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
	
		@append @headers,@currents,@process,@trail,divide,@receiver,@payments,@transports,@bills,@orders,@footers
		#$("#tabs")?.tabs()


		@navigate '!/orderdetail'
	
module.exports = OrderDetail