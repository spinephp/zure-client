Spine   = require('spine')
Qiye = require('models/qiye')
Navigation = require('models/navigation')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Goodclass = require('models/goodclass')
Goodconsult = require('models/goodconsult')
#Goodcare = require('models/goodcare')
Order = require('models/order')
Cart = require('models/cart')
User = require('models/user')
$       = Spine.$
myYunruiDialog = require('../controllers/myYunruiDialog')
myCartDialog = require('controllers/myCartDialog')

class Headers extends Spine.Controller
	className: 'headers'

	elements:
		".header p":"company"
		".headers ul:first-child dt":"menu"
		"header ul li button":"btnsEl"
		"ol li select":"selectEl"
	
	events:
		"click .header ol li[data-tab=addfavorite]":"addfavorite"
		"click .header ol li[data-tab=sethomepage]":"sethomepage"
		"change ol li select":"setLanguage"

	constructor: ->
		super
		@active @change
		
		@qiye = $.Deferred()
		@navigation = $.Deferred()
		@currency = $.Deferred()
		@language = $.Deferred()
		#@default = $.Deferred()

		Qiye.bind "refresh",=>@qiye.resolve()
		Navigation.bind "refresh",=>@navigation.resolve()
		Currency.bind "refresh",=>@currency.resolve()
		Language.bind "refresh",=>@language.resolve()
		User.bind "refresh",=>
			Order.fetch()
		User.fetch()
		Cart.bind 'change', @render

		Spine.bind 'logout',->
			data = 
				user:User.first().name
				action:'custom_logout'
				token:$.fn.cookie 'PHPSESSID'
			$.post "? cmd=Logout", data, (result)->
				if result[0] is "{"
					obj = JSON.parse(result)
					if typeof (obj) is "object"
						unless obj.id is -1
							User.destroyAll()
							#@navigate '!/customs/login'
						else 
							alert(obj.username) # 显示登录失败信息
		$(window).unload (e)->
			Spine.trigger 'logout' if User.count() > 0 and e.clientX<=0 and e.clientY<0

	render: =>
		@html require('views/showheader')(@item)
		$(document).attr "title", @item.default.translates @item.qiye.names
		$(@btnsEl).eq(0).button
			icons: 
				primary: "ui-icon-person"
				secondary: "ui-icon-triangle-1-s"
			text: true
		.delay(150).hover @_myYunrui,->
			myDiv = $("#myYunruiDialog")
			setTimeout (->myDiv?.dialog?("close") unless myDiv.hasClass('hover')),150

		$(@btnsEl).eq(1).button
			icons:
				primary: "ui-icon-cart"
				secondary:"ui-icon-triangle-1-e"
			text: true
		.delay(150).hover @_myOrder,->
			myDiv = $("#myCartDialog")
			setTimeout (->myDiv?.dialog?("close") unless myDiv.hasClass('hover')),150
		#$(@selectEl).combobox()
		Spine.trigger("headerrender",@item)

	change: (item) =>
		try
			$.when(@qiye,@navigation,@currency,@language).done =>
				rec = Default.first()
				unless rec?
					rec = new Default id:1,languageid:2,currencyid:1
					rec.save()
					
				@item = 
					qiye:Qiye.first()
					menus:Navigation.all()
					languages:Language.all()
					currencys:Currency
					default:rec
					carts:Cart
				@render()
		catch err
			console.log err.message

	_myYunrui: ->
		myYunruiDialog().open user:User.first(),orders:Order,defaults:Default.first(),consults:Goodconsult

	_myOrder: ->
		orders = JSON.parse(sessionStorage.getItem("orders"))
		proids = []
		if "" is orders || null is orders # 向服务器查寻全部数据
			proids = (rec.proid for rec in Cart.all())
		else # 查询购物车中商品
			proids = (rec.proid for rec in Cart.all() when rec.proid is null)
		if proids.length>0
			val = "(" + proids.join(",") + ")"
			cond = [{field:"id",value:proids,operator:"in"}]
			data = { cond:cond, filter: ["id","classid","picture","size","price","returnnow"], token: $.fn.cookie 'PHPSESSID' }
			Cart.getOrder(data)
		else
			default1 = Default.first()
			currency = Currency.find default1.currencyid
			myCartDialog().open carts:Cart.all(),currency:currency,defaults:default1,goodclass:Goodclass

	addfavorite:(e)->
		e.stopPropagation()
		domain = @item.qiye.domain
		company = @item.qiye.names[@default.languageid-1]
		if document.all
			window.external.addFavorite(@item.qiye.domain, company)
		else if window.sidebar
			window.sidebar.addPanel(company, domain, "")
		else # 添加收藏的快捷键
			ctrl = if (navigator.userAgent.toLowerCase()).indexOf('mac') isnt -1 then 'Command/Cmd' else 'CTRL'
			alert('添加失败\n您可以尝试通过快捷键' + ctrl + ' + D 加入到收藏夹~')

	sethomepage:(e) ->
		e.stopPropagation()
		if document.all # 设置IE
			document.body.style.behavior = 'url(#default#homepage)'
			document.body.setHomePage(document.URL)
		else # 网上可以找到设置火狐主页的代码，但是点击取消的话会有Bug，因此建议手动设置
			alert("设置首页失败，请手动设置！")
			
	setLanguage:(e)=>
		e.stopPropagation()
		id = parseInt $(e.target).val(),10
		switch $(@selectEl).index e.target
			when 0
				@item.default.languageid = id
			when 1
				@item.default.currencyid = id
		@item.default.save()
		@render()
		#window.location.reload()
		#@navigate '/home'
		
module.exports = Headers