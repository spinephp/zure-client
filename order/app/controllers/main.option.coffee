Spine   = require('spine')
Currency = require('models/currency')
Default = require('models/default')
Cart = require('models/cart')
Goodclass = require('models/goodclass')

$       = Spine.$

class OrderOption extends Spine.Controller
	className: 'orderoption'
	
	elements:
		'div.tabsbox-eval':'tabsEl'
		'button':'btnsEl'
		'input[name=selector]':'selectorsEl'
		'.num1 input':'spinEl'

	events:
		'click input[name=selectall]':'selectallClick'
		'click a[href=#]':'deleteClick'
		'click table tr:eq(-2) a':'delselClick'
		
	constructor: ->
		super
		@active @change

		@currency = $.Deferred()
		@default = $.Deferred()
		@cart = $.Deferred()
		@goodsclass = $.Deferred()
		Currency.bind "refresh",=>@currency.resolve()
		Default.bind "refresh",=>@default.resolve()
		Cart.bind "refresh",=>@cart.resolve()
		Goodclass.bind "refresh",=>@goodsclass.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@item.currency = Currency.find @item.default.currencyid
				@render()
  
	render: ->
		@html require("views/order")(@item)
		@salenumber = $(@spinEl).spinner
			min:1
			
			# 绑定每个订单项数量输入框 spinner 数据改变时的事件
			spin:(event,ui)=>
				@orderNumberChange(event,ui.value)
			change:(event,ui)=>
				@orderNumberChange(event,$(event.target).val())
		@btnPickGoods = $(@btnsEl).eq(0).button()
		@btnPickGoods.button
			icons:
				primary: "ui-icon-cart"
			text: true
		.click (e)=> # 继续购物按键
			e.stopPropagation()
			apro = Cart.last()
			location.href = "? cmd=ShowProducts&prosid="+apro.proid
		$(@btnsEl).eq(1).button
			icons: 
				primary: "ui-icon-plusthick"
				secondary: "ui-icon-carat-1-e"
			text: true
		.click (e)=> # 去结算按键
			e.stopPropagation()
			location.href = "? cmd=ShowOrderInfo&token="+$.fn.cookie 'PHPSESSID'
	
	change: (params) =>
		try
			$.when(@cart,@goodsclass,@currency,@default).done =>
				default1 = Default.first()
				@item = 
					default:default1
					currency:Currency.find default1.currencyid
					klass:Goodclass
					orders:Cart
				@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Goodtitle\nerror: #{err.message}"
			
	# 绑定删除选定商品点击事件
	delselClick:()->
		if confirm @item.default.translate("Delete all the selected items from the order")+"?"
			for sel in @selectorsEl when sel.checked
				orderid = $(sel).attr("value")
				apro = AOrder.findByAttribute("id", orderid)
				apro.destroy()
				@item.orders = Cart
				@render()

	# 绑定每个订单项删除按键的点击事件
	deleteClick:(e)=>
		orderid = $(e.target).attr("order-id")
		if orderid
			apro = Cart.findByAttribute("id", orderid)
			if apro
				if confirm(@item.default.translate("Delete the items from the order")+"("+@item.default.translates(Goodclass.find(apro.aRecordEx().classid).longNames())+apro.aRecordEx().size+") ?")
					apro.destroy()
					@item.orders = Cart
					@render()
			
	# 绑定全选多选框点击事件
	selectallClick:(e)->
		e.stopPropagation()
		state = $(e.target).is ':checked'
		$(@selectorsEl).prop 'checked',state
		
	orderNumberChange:(e,value)->
		e.stopPropagation()
		proid = $(e.target).attr("pro-id")
		apro = Cart.findByAttribute("proid", proid)
		apro.number = value
		apro.save()
		
		s = 0
		b = 0
		for rec in Cart.all()
			s += rec.number * rec.aRecordEx().price 
			b += rec.aRecordEx().returnnow
		s /= @item.currency.exchangerate
		b /= @item.currency.exchangerate
		c = s - b
		$("#my_order td b").eq(0).parent().html("<b>"+@item.currency.symbol+s.toFixed(2)+"</b><br />-"+@item.currency.symbol+b.toFixed(2))
		$("#my_order td b").eq(1).html(@item.currency.symbol+c.toFixed(2))
	
module.exports = OrderOption
