Spine   = require('spine')
Qiye = require('models/qiye')
Navigation = require('models/navigation')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Cart = require('models/cart')
Consignee = require('models/consignee')
Payment = require('models/payment')
Transport = require('models/transport')
Bill = require('models/bill')
Billfree = require('models/billfree')
Billsale = require('models/billsale')
Billcontent = require('models/billcontent')
AOrder = require('models/cart')
Product   = require('models/orderproducts')
Province = require('models/province')
User = require('models/user')

Manager = require('spine/lib/manager')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Receiver = require('controllers/orderinfo.consignee')
Payments = require('controllers/orderinfo.payment')
Transports = require('controllers/orderinfo.transport')
Bills = require('controllers/orderinfo.bill')
Orders = require('controllers/orderinfo.product')

loginDialog = require('controllers/loginDialog')

#Spine.Model.host = "http://127.0.0.1/woo/"

class OrderInfo extends Spine.Controller
	className: 'orderinfo'
  
	constructor: ->
		super
	
		@headers     = new Headers
		@footers     = new Footers
		@receiver    = new Receiver
		@payments    = new Payments
		@transports  = new Transports
		@bills = new Bills
		@orders = new Orders
		
		data = token:$.fn.cookie 'PHPSESSID'
		$.getJSON "? cmd=IsLogin", data,(result)=>
			if result.login
				@append @headers,status,divide,@receiver,@payments,@transports,@bills,@orders,@footers
				@navigate '/orderinfo'
			else
				loginDialog().open(default:Default.first(),user:User,sucess:->location.reload())

		@routes
			'/orderinfo/edit0': (params) -> 
				@headers.active(params)
				@receiver.edit.active(params)
				@payments.show.active(params)
				@transports.show.active(params)
				@bills.show.active(params)
				@orders.show.active(params)
				@footers.active(params)
			'/orderinfo/edit1': (params) -> 
				@headers.active(params)
				@payments.edit.active(params)
				@receiver.show.active(params)
				@transports.show.active(params)
				@bills.show.active(params)
				@orders.show.active(params)
				@footers.active(params)
			'/orderinfo/edit2': (params) -> 
				@headers.active(params)
				@transports.edit.active(params)
				@receiver.show.active(params)
				@payments.show.active(params)
				@bills.show.active(params)
				@orders.show.active(params)
				@footers.active(params)
			'/orderinfo/edit3': (params) -> 
				@headers.active(params)
				@bills.edit.active(params)
				@receiver.show.active(params)
				@payments.show.active(params)
				@transports.show.active(params)
				@orders.show.active(params)
				@footers.active(params)
			'/orderinfo':  ->
				@headers.active()
				@receiver.show.active()
				@payments.show.active()
				@transports.show.active()
				@bills.show.active()
				@orders.show.active()
				@footers.active()

		Qiye.fetch()
		Navigation.fetch()
		Language.fetch()
		Default.fetch()
		Cart.fetch()
		Currency.fetch()
		Province.fetch()
		Product.bind "refresh update change",->
			Consignee.fetch()
		AOrder.bind "refresh update change",->
			values = (parseInt(item.proid) for item in @all())
			params = 
				data:{ filter: Product.attributes, cond:[{field:"id",value:values,operator:"in"}],token: $.fn.cookie 'PHPSESSID' } 
				processData: true
			Product.fetch(params)
		AOrder.fetch()
		Bill.fetch()
		Billfree.fetch()
		Billsale.fetch()
		Billcontent.fetch()
		Billfree.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText
		Payment.fetch()
		Transport.fetch()
		
		status = $("<ol class='orderstate'><li><span class='finished'>1.我的订单</span></li><li><span class='current'>2.填写核对订单信息</span></li><li><span>3.成功提交订单</span></li></ol>")
		divide = $('<div class="infotitle">填写并核对订单信息</div>')
	
		#@append @headers,status,divide,@receiver,@payments,@transports,@bills,@orders,@footers

		#@navigate '/orderinfo'
	
module.exports = OrderInfo