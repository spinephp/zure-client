Spine   = require('spine')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Good = require('models/good')
Goodclass = require('models/goodclass')
Goodeval = require('models/goodeval')
Theeval = require('models/theeval')
Thefeel = require('models/thefeel')
Cart = require('models/cart')
$       = Spine.$
addOrderDialog = require('controllers/addOrderDialog')

class Goodsinfomation extends Spine.Controller
	className: 'goodsinfomations'
	
	elements:
		'p button':'btnsEl'
		'p input[type=text]':'spinnerEl'
	
	events:
		'click .goodinfomation >img': 'showGood'
		'click p >a': 'showGoods'
  
	constructor: ->
		super
		@active @change
		
		@goodclass = $.Deferred()
		@goodeval = $.Deferred()
		@good = $.Deferred()
		@currency = $.Deferred()
		@language = $.Deferred()
		@default = $.Deferred()

		Goodclass.bind "refresh",=>@goodclass.resolve()
		Goodeval.bind "refresh",=>@goodeval.resolve()
		Good.bind "refresh",=>@good.resolve()
		Currency.bind "refresh",=>@currency.resolve()
		Language.bind "refresh",=>@language.resolve()
		Default.bind "refresh",=>@default.resolve()

		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()
	 
	render: =>
		@html require('views/goodinfomation')(@item)
		@salenumber = $(@spinnerEl).spinner(min:1)
		.click (e)=>
			e.stopPropagation()

		@btnAddOrder = $(@btnsEl).eq(0).button()
		if @item.good.cansale is 'Y'
			@btnAddOrder.button
				icons:
					primary: "ui-icon-cart"
				text: true
			.click (e)=>
				e.stopPropagation()
				@_addOrder()
		else
			@btnAddOrder.button
				icons: 
					primary: "ui-icon-cancel"
				text: true
			.button('option', 'label', '已下架').button("option", "disabled", true)
	
	change: (params) =>
		try
			$.when(@good,@goodclass,@goodeval,@currency,@language,@default).done =>
				the = if /\/review\//.test params.match[0] then Theeval else Thefeel
				if the.exists params.id
					reval = the.first()
					good = Good.find reval.proid
					default1 = Default.first()
					@item = 
						klass:Goodclass.find good.classid
						eval:Goodeval
						good:good
						languages:Language.all()
						currencys:Currency.find default1.currencyid
						defaults: default1
					@render()
		catch err
			console.log err.message

	# 加入购物车，并显示购物车汇总信息
	_addOrder:->
		cart = Cart.findByAttribute("proid", @item.good.id)
		n = parseInt(@salenumber.spinner("value"))
		if cart?
			cart.number += n
		else 
			cart = new Cart proid:@item.good.id, number: n, time: new Date() 
		cart.save()

		n = m = 0
		exchangerate = @item.currencys.exchangerate
		symbol = @item.currencys.symbol
		Cart.each (item)->
			url = "? cmd=Product"
			n += 1
			jQuery.ajax
				type: 'get'
				url: url
				data: {cond:[{'field':'id',value: cart.proid,operator:'eq'}], filter: ["price"], token: $.fn.cookie 'PHPSESSID' }
				async: false   #ajax执行完毕后才执行后续指令
				success: (result) =>
					obj = JSON.parse(result)
					if typeof (obj[0]) is "object"
						m += item.number * obj[0].price/exchangerate
		addOrderDialog().open({ kind: n, price: m ,symbol:symbol})

	showGood:(e)->
		e.stopPropagation()
		location.href = '?cmd=ShowProducts&gid='+@item.good.id

	showGoods:(e)->
		e.stopPropagation()
		id = $(e.target).attr 'data-id'
		if id?
			location.href = '?cmd=ShowProducts&'+id


module.exports = Goodsinfomation