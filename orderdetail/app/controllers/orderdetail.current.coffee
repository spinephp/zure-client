Spine   = require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')
$       = Spine.$

class manageOrder  extends Spine.Controller
  
	constructor: (params) ->
		super params

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
		'click .print': 'print'
	
	elements: 
		'p': 'pEl'
  
	constructor: ->
		super

		@orderid = $.getUrlParam "orderid"

		@active @change
		Order.bind('refresh change', @render)
		Orderstate.bind('refresh change', @render)
  
	render: =>
		try
			if Order.count() and Orderstate.count()
				order = Order.find(@orderid)
				item = Orderstate.find(order.stateid)
				@html require('views/showcurrentstate')({order:order,state:item})
				switch order.stateid
					when 2
						if order.downpayment is 100
							if order.paymentid is 7 # 在线支付
								dom1 = "<buttom class='gopayment'>去付款</buttom>"
							else
								dom2 = "请你及时付款"
						else 
							dom1 = "<buttom class='prncontract'>打印合同</buttom><buttom class='uploadcontract'>回传合同</buttom>"
				@pEl[0].append dom1 if dom1?
				@pEl[1].append dom2 if dom2?
		catch err
			console.log err.message
	
	change: (params) =>
		@render()

	print: ->
		w = window.open()
	
module.exports = CurrentState