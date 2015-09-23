Spine   = require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')

$       = Spine.$

class manageOrder  extends Spine.Controller
  
	constructor: (params) ->
		super params

		Order.bind "beforeUpdate", ->
			Order.url = "woo/index.php"+Order.url if Order.url.indexOf("woo/index.php") is -1
			Order.url += "&token="+sessionStorage.token unless Order.url.match /token/
	
	eco:->
		'ordercurrentstate'

# 订单审核
class orderCheck extends manageOrder

	elements:
		"button":"buttons"
		"input[type=checkbox]":"constract"
  
	constructor: (params) ->
		super params

	eco: ->
		'stateordercheck0'

class orderPrint extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'printed'
  
	constructor: (params) ->
		super params

	eco: ->
		'stateorderprint'

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

class orderReturned extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'returned'
  
	constructor: (params) ->
		super params

	eco: ->
		'stateorderreturned'

	returned: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0
				@order.stateid = 4
				@order.save()
				@navigate('/sysadmins/order',@order.id,'show')
			else
				@navigate('/sysadmins/order')
		catch err
			@log err
		finally
			Order.url = oldUrl

class CurrentState0 extends Spine.Controller
	className: 'currentstate0'
  
	constructor: ->
		super

		@active @change
		Order.bind('refresh change', @render)
		Orderstate.bind('refresh change', @render)
  
	render: =>
		try
			if @order and Orderstate.count()
				item = Orderstate.find(@order.stateid)
				@html require("views/#{@eco}")({order:@order,state:item})
		catch err
			@log "file: sysadmin.order.current.coffee\nclass: CurrentState\nerror: #{err.message}"
	
	change: (params) =>
		@order = Order.find params.id
		state = null
		switch parseInt @order.stateid
			when 1
				state = new orderCheck el:@el,order:@order
			when 2
				state = new orderPrint el:@el,order:@order
			when 3
				state = new orderReturned el:@el,order:@order
		@eco = state.eco()
		@render()

module.exports = CurrentState0