Spine   = require('spine')
Header = require('models/header')
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
Order = require('models/order')
Product   = require('models/orderproducts')
Province = require('models/province')
Orderstate = require('models/orderstate')
Thisstate = require('models/theorderstate')
User = require('models/user')
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

loginDialog = require('controllers/loginDialog')

#Spine.Model.host = "http://127.0.0.1/woo/"

class Main extends Spine.Controller
	className: 'main'
  
	constructor: ->
		super

		$.fn.getUrlParam = (name) ->
			results = new RegExp('[\\?& ]' + name + '=([^&#]*)')
						.exec(decodeURI(window.location.href))
			return 0 if not results
			results[1] || 0

		$.fn.cookie = (c_name)->
			if document.cookie.length>0
				c_start=document.cookie.indexOf(c_name + "=")
				if c_start isnt -1
					c_start=c_start + c_name.length+1 
					c_end=document.cookie.indexOf(";",c_start)
					c_end=document.cookie.length if c_end is -1 
					return unescape(document.cookie.substring(c_start,c_end))
			return ""
			
		data = token:$.fn.cookie 'PHPSESSID'
		$.getJSON "? cmd=IsLogin", data,(result)=>
			if result.login
				#Order.fetch()
				@append @headers,@currents,@process,@trail,@receiver,@payments,@transports,@bills,@orders,@footers
				@navigate '!/orderdetail'
			else
				loginDialog().open(default:Default.first(),user:User,sucess:->location.reload())
	
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
			'!/orderdetail': (params) ->
				@headers.active(params)
				@currents.active(params)
				@process.active(params)
				@trail.active(params)
				@receiver.active(params)
				@payments.active(params)
				@transports.active(params)
				@bills.active(params)
				@orders.active(params)
				@footers.active(params)
		

		Order.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText
		
		Order.bind "refresh", ->
			Product.fetch()

		Header.fetch()
		Qiye.fetch()
		Navigation.fetch()
		Language.fetch()
		Default.fetch()
		Cart.fetch()
		Currency.fetch()
		Orderstate.fetch()
		Thisstate.fetch()
		Province.fetch()
		Consignee.fetch()
		Bill.fetch()
		Billfree.fetch()
		Billsale.fetch()
		Billcontent.fetch()
		Payment.fetch()
		Transport.fetch()
		
	
		status = $("<div id='tabs'><ul><li><a href='.trail' >订单跟踪</a></li><li><a href='.pay' >付款信息</a></li></ul></div>")
		#divide = $('<div class="infotitle">订单信息</div>')
	
		@append @headers,@currents,@process,@trail,@receiver,@payments,@transports,@bills,@orders,@footers
		#$("#tabs")?.tabs()


		@navigate '!/orderdetail'
	
module.exports = Main