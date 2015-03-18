Spine   = require('spine')
Consignee = require('models/consignee')
Payment = require('models/payment')
Transport = require('models/transport')
Currency = require('models/currency')
Default = require('models/default')
Bill = require('models/bill')
Billfree = require('models/billfree')
Billsale = require('models/billsale')
Billcontent = require('models/billcontent')
Product   = require('models/orderproducts')
Cart   = require('models/cart')
Order   = require('models/order')
$       = Spine.$

class Show extends Spine.Controller
	className: 'show'

	events:
		'click .repair': 'repair'
		'click a[data-product]': 'product'
		'click .sumbitorder': 'sumbitOrder'

	constructor: ->
		super
		@active @change
			
		@good = $.Deferred()
		@cart = $.Deferred()
		@transport = $.Deferred()
		@currency = $.Deferred()

		Currency.bind "refresh",=>@currency.resolve()
		Product.bind "refresh",=>@good.resolve()
		Cart.bind "refresh",=>@cart.resolve()
		Transport.bind "refresh",=>@transport.resolve()

	render: ->
		@html require('views/showorder')(@item)
		btn = $(".sumbitorder")
		if params?
			btn.attr("disabled", "disabled")
		else
			btn.removeAttr("disabled")

	change: (item) =>
		try
			$.when(@good,@cart,@transport,@currency).done =>
				rec = Default.first()
				unless rec?
					rec = new Default id:1,languageid:2,currencyid:1
					rec.save()
					
				@item = 
					orders:Cart
					goods:Product
					carriagecharges:Transport.getCurrent()?.charges or '0'
					default:rec
					currency:Currency.find rec.currencyid
				@render()
		catch err
			console.log err.message

	repair: ->
		window.location.href="? cmd=ShowOrder&token="+sessionStorage.token

	product:(e)->
		id = $(e.target).attr 'data-product'
		window.location.href="? cmd=ShowProduct&prosid="+$.trim(id)
	  
	sumbitOrder:->
		# 计算供货天数
		shipdate = 0
		tem = $("td.shipdate p").text().replace("现货","0 天").replace("天",",").split(",")
		shipdate = Math.max(shipdate,parseInt(item)) for item in tem when item isnt ""

		billtypeid = Bill.getCurrent().id
		
		curBill = if billtypeid is '1' then Billfree.getCurrent() else Billsale.getCurrent()
		
		Order.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		Order.one "ajaxSuccess",(data, text, xhr) ->
			# 删除购物车中商品
			Cart.destroyAll()
			window.location.href="? cmd=ShowOrderDetail&orderid="+data.id+"&token="+sessionStorage.token

		Order.url += "&token="+sessionStorage.token if not Order.url.match /token/

		item = new Order
			id:null
			code:null
			products:Cart.all()
			shipdate:shipdate
			consigneeid: Consignee.getCurrent().id
			paymentid: Payment.getCurrent().id
			transportid: Transport.getCurrent().id
			billtypeid: billtypeid
			billid: curBill.id
			billcontentid:Billcontent.getCurrent().id
			carriagecharge:Transport.getCurrent().charges
			stateid:'1'
		item.save()

class Edit extends Spine.Controller
	className: 'edit'

	constructor: ->
		super
		@active @change

	render: ->
		@html require('views/showorder')( Cart.first())

	change: (params) =>
		@render()

class Orders extends Spine.Stack
	className: 'orders stack'

	controllers:
		show: Show
		edit: Edit

module.exports = Orders