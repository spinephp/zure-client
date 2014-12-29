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
		'p button':'btnsEl'
		'input[type=text]':'spinnerEl'
		'input[name=selector]':'selectorsEl'
		'.num1 input':'spinEl'

	events:
		'change p input[type=text]':'spinChange'
		'click input[name=selectall]':'selectallClick'
		'click a[href=#]':'deleteClick'
		'click table tr:eq(-2) a':'delselClick'
		
	constructor: ->
		super
		@active @change

		@currency = $.Deferred()
		@default = $.Deferred()
		@cart = $.Deferred()
		Currency.bind "refresh",=>@currency.resolve()
		Default.bind "refresh",=>@default.resolve()
		Cart.bind "refresh",=>@cart.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@item.currency = Currency.find @item.default.currencyid
				@render()
  
	render: ->
		@html require("views/order")(@item)
		@salenumber = $(@spinnerEl).spinner(min:1)
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
			location.href = "? cmd=ShowOrderInfo&token="+sessionStorage.token
	
	change: (params) =>
		try
			$.when(@cart,@currency,@default).done =>
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
			
	# 绑定每个订单项数量输入框 spinner 数据改变时的事件
	spinChange:(event, ui) ->
		proid = $(this).attr("pro-id")
		n = ui.value || parseInt($(this).val())
		apro = Cart.findByAttribute("proid", proid)
		apro.number = n
		apro.save()
		@orderNumberChange()

	# 绑定每个订单项删除按键的点击事件
	deleteClick:(e)->
		orderid = $(e.target).attr("order-id")
		if orderid
			apro = Cart.findByAttribute("id", orderid)
			if apro
				if confirm(@item.default.translate("Delete the items from the order")+"("+apro.aRecordEx().longname+apro.aRecordEx().size+") ?")
					apro.destroy();
			
	# 绑定全选多选框点击事件
	selectallClick:(e)->
		check = $(e.target).checked
		sel.checked=check for sel in $(@selectors)
	
	# 订单数量选择框 spinner
	$(@spinEl).spinner
		min: 1
		max: 2000
		
		# spin 按键按下事件发生时，触发 spinner 的 spinchange 事件，更新订单的总价格
		# 因为 spin 按键按下时，spinchange 事件不自动触发，要等失支焦点时才触发
		spin: (event, ui) ->
			@trigger("spinchange",ui)
	
	orderNumberChange:()->
		s = 0
		s += rec.number * rec.aRecordEx().price for rec in Cart.all()
		$("#my_order td b").html("¥"+s.toFixed(2))
	
module.exports = OrderOption
