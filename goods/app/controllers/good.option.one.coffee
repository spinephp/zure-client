Spine	= require('spine')
Good = require('models/good')
Goodclass = require('models/goodclass')
Goodeval = require('models/goodeval')
Gooduse = require('models/gooduse')
Goodsharp = require('models/goodsharp')
Currency = require('models/currency')
Default = require('models/default')
Grade = require('models/grade')
Cart = require('models/cart')
Physicoindex = require('models/physicoindex')
Chemicalindex = require('models/chemicalindex')
User = require('models/user')

$		= Spine.$

addOrderDialog = require('controllers/addOrderDialog')
GoodEvals = require('controllers/good.option.one.eval')
GoodConsults = require('controllers/good.option.one.consult')
loginDialog = require('controllers/loginDialog')

class Goodtitle extends Spine.Controller
	className: 'goodtitle'
  
	elements:
		'div.tabsbox-eval':'tabsEl'
		'p button':'btnsEl'
		'p input[type=text]':'spinnerEl'
  
	constructor: ->
		super
		@active @change

		@good = $.Deferred()
		@goodclass = $.Deferred()
		@goodeval = $.Deferred()
		@currency = $.Deferred()
		@default = $.Deferred()
		Good.bind "refresh",=>@good.resolve()
		Goodclass.bind "refresh",=>@goodclass.resolve()
		Goodeval.bind "refresh",=>@goodeval.resolve()
		Currency.bind "refresh",=>@currency.resolve()
		Default.bind "refresh",=>@default.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@item.currency = Currency.find @item.default.currencyid
				@render()
  
	render: ->
		@html require("views/goodtitle")(@item)
		@salenumber = $(@spinnerEl).spinner(min:1)
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
		$(@btnsEl).eq(1).button
			icons: 
				primary: "ui-icon-plusthick"
			text: true
		.click (e)=>
			e.stopPropagation()
			@_addCare()
	
	change: (params) =>
		try
			$.when(@good,@goodeval,@goodclass,@currency,@default).done =>
				if Good.exists params.id
					good = Good.find params.id
					default1 = Default.first()
					@item = 
						good:good
						klass:Goodclass.find good.classid
						eval:Goodeval.findAllByAttribute 'proid':good.id
						default:default1
						currency:Currency.find default1.currencyid
					@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Goodtitle\nerror: #{err.message}"

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
		exchangerate = @item.currency.exchangerate
		symbol = @item.currency.symbol
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
		addOrderDialog().open({ kind: n, price: m ,default:@item.default,symbol:symbol})

	_addCare: ->
		url = "? cmd=ProductCare"
		item = 
			proid:@item.good.id
			userid:'?userid'
			currencyid:@item.currency.id
			exchangerate:@item.currency.exchangerate
			price:@item.good.price
			date:'?time'
		token = $.fn.cookie 'PHPSESSID'
		$.post url,{token:token,item:item},(result)=>
			if result.id is -1
				switch result.error
					when 'Not logged!'
						loginDialog().open(default:Default.first(),user:User,sucess:=>@_addCare())
					when "Access Denied"
						alert result.error
					else
						alert @item.default.translate result.error
			else
				alert @item.default.translatem(['Width focus on','successful'])+'!'


class Gooddetail extends Spine.Controller
	className: 'gooddetail'
  
	constructor: ->
		super
		@active @change
		
		@good = $.Deferred()
		@goodclass = $.Deferred()
		@goodsharp = $.Deferred()
		@physicoindex = $.Deferred()
		@chemicalindex = $.Deferred()
		@default = $.Deferred()
		Good.bind "refresh",=>@good.resolve()
		Goodclass.bind "refresh",=>@goodclass.resolve()
		Goodsharp.bind "refresh",=>@goodsharp.resolve()
		Physicoindex.bind "refresh",=>@physicoindex.resolve()
		Chemicalindex.bind "refresh",=>@chemicalindex.resolve()
		Default.bind "refresh",=>@default.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
		
		Goodsharp.fetch()
		Physicoindex.fetch()
		Chemicalindex.fetch()
  
	render: ->
		
		$(@el).tabs('destroy') if $(@el).hasClass 'ui-tabs'
		@html require("views/gooddetail")(@item)
		$(@el).tabs()
	
	change: (params) =>
		try
			$.when(@good,@goodsharp,@goodclass,@physicoindex,@chemicalindex,@default).done =>
				if Good.exists params.id
					good = Good.find params.id
					default1 = Default.first()
					@item = 
						good:good
						klass:Goodclass.find good.classid
						sharp:Goodsharp.find good.sharp
						physicoindex:Physicoindex.all()
						chemicalindex:Chemicalindex.find good.chemicalindex
						default:default1
					@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Gooddetail\nerror: #{err.message}"

class AGood extends Spine.Controller
	className: 'agood'
  
	constructor: ->
		super
		@active @change
		
		@title = new Goodtitle
		@detail = new Gooddetail
		@eval = new GoodEvals
		@consult = new GoodConsults
		
		@append @title,@detail,@eval,@consult

		Grade.fetch()
		
	change:(params)=>
		Goodeval.append [params.id] #unless Goodeval.findByAttribute 'proid',params.id
		Gooduse.append [params.id] #unless Gooduse.findByAttribute 'proid',params.id
		@title.active params
		@detail.active params
		@eval.active params
		@consult.active params

module.exports = AGood