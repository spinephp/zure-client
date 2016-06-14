Spine   = require('spine')
Default = require('models/default')
Orderstate = require('models/orderstate')
Order = require('models/order')
$       = Spine.$

class manageOrder  extends Spine.Controller
  
	constructor: (params) ->
		super params

		@orderid = $.fn.getUrlParam 'orderid'
		Order.bind "beforeUpdate", ->
			Order.url = "woo/index.php"+Order.url if Order.url.indexOf("woo/index.php") is -1
	
	eco:->
		'ordercurrentstate'

class orderPrint extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'printed'
  
	constructor: (params) ->
		super params

	eco: ->
		'stateordercontract'

	printed: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		e.preventDefault();
		e.stopPropagation();
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0
				@order.stateid = 3
				@order.save()
				@navigate('/sysadmins/order',@order.id,'show')
			else if i is 1
				window.open("?cmd=Contract&orderid=#{@order.id}&token=#{sessionStorage.token}")
			else
				@navigate('/sysadmins/order')
		catch err
			@log err
		finally
			Order.url = oldUrl

class CurrentState extends Spine.Controller
	className: 'currentstate'
  
	events:
		'click button': 'print'
	
	elements: 
		'p': 'pEl'
  
	constructor: ->
		super

		@orderid = $.fn.getUrlParam "orderid"

		@active @change
		
		@default = $.Deferred()
		@order= $.Deferred()
		@orderstate = $.Deferred()
		Default.bind "refresh",=>@default.resolve()
		Order.bind "refresh",=>@order.resolve()
		Orderstate.bind "refresh",=>@orderstate.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
  
	render: =>
		@html require('views/showcurrentstate') @item
		switch @item.order.stateid
			when 2
				if order.downpayment is 100
					if @item.order.paymentid is 7 # 在线支付
						dom1 = "<buttom class='gopayment'>"+@item.default.translate("To pay for")+"</buttom>"
					else
						dom2 = @item.default.translate "Please pay in time"
				else 
					dom1 = "<buttom class='prncontract'>"+@item.default.translate("Print contract")+"</buttom><buttom class='uploadcontract'>"+@item.default.translate("Return contract")+"</buttom>"
		@pEl[0].append dom1 if dom1?
		@pEl[1].append dom2 if dom2?
	
	change: (params) =>
		try
			$.when(@order,@orderstate,@default).done =>
				default1 = Default.first()
				theOrder = Order.find @orderid
				theorderstate = Orderstate.find(theOrder.stateid)
				@item = 
					default:default1
					order:theOrder
					state:theorderstate
				@render()
		catch err
			@log "file:ordertetail.product.coffee\nclass:Products\nerror: #{err.message}"

	print: ->
		window.open("?cmd=Contract&orderid=#{@orderid}&token=#{@token}")
	
module.exports = CurrentState