
Spine   = require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')

$       = Spine.$

class manageOrder  extends Spine.Controller
  
	constructor: (params) ->
		super params
		@token = $.fn.cookie('PHPSESSID')
		@params = params
		Order.bind "beforeUpdate", =>
			Order.url = "woo/index.php"+Order.url if Order.url.indexOf("woo/index.php") is -1
			Order.url += "&token="+@token unless Order.url.match /token/
	
	eco:->
		'show'

# 订单审核
class orderCheck extends manageOrder

	elements:
		"button":"buttons"
		"input[type=checkbox]":"constractEl"
  
	events:
		'click button': 'pass'
  
	constructor: (params) ->
		super params

	eco: ->
		'check'

	pass: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		e.stopPropagation()
		oldUrl = Order.url
		try
			threw "预付歀与质保金之和大于 100！" if @params.order.downpayment + @params.order.guarantee > 100
			i = $('button',@el).index e.target
			if i is 0
				if $(@constractEl).is(":checked")
					@params.order.stateid = 2 # 签署合同
				else
					if @params.order.downpayment is 0
						if @params.order.shipdate is 0
							if @params.order.guarantee isnt 100
								@params.order.stateid = 9 # 支付货款
							else
								@params.order.stateid = 10 # 准备发货
						else
							@params.order.stateid = 4 # 准备生产
					else
						@params.order.stateid = 3 # 预付款
			else
				@params.order.stateid = 14 #取消订单
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')
		catch err
			alert err.message
		finally
			Order.url = oldUrl

# 签署合同
class orderPrint extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'printed'
  
	constructor: (params) ->
		super params

	eco: ->
		'print'

	printed: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		e.preventDefault();
		e.stopPropagation();
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # 确认合同
				if @params.order.downpayment is 0
					if @params.order.shipdate is 0
						if @params.order.guarantee isnt 100
							@params.order.stateid = 9 # 支付货款
						else
							@params.order.stateid = 10 # 准备发货
					else
						@params.order.stateid = 4 # 准备生产
				else
					@params.order.stateid = 3 # 预付款
			else if i is 1 # 查看合同
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			else # 取消订单
				@params.order.stateid = 14 # 取消订单
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')
		catch err
			@log err
		finally
			Order.url = oldUrl

class orderReturned extends manageOrder

	constructor: (params) ->
		super params

	eco: ->
		'returned'

# 预付款
class orderAdvance extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'prepaid'
  
	constructor: (params) ->
		super params

	eco: ->
		'advance'

	prepaid: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # 点击了 [已预付] 按键
				@params.order.stateid = 4 #准备生产
			else if i is 1 # 查看合同
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			else # 取消订单
				@params.order.stateid = 14 # 取消订单
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')

		catch err
			@log err
		finally
			Order.url = oldUrl

# 支付货款
class orderPayment extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'payment'
  
	constructor: (params) ->
		super params

	eco: ->
		'payment'

	payment: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # 点击了 [已支付] 按键
				@params.order.stateid = 10 # 准备发货
			else if i is 1 # 查看合同
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			else # 取消订单
				@params.order.stateid = 14 # 取消订单
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')

		catch err
			@log err
		finally
			Order.url = oldUrl

# 准备发货
class orderShip extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'ship'
  
	constructor: (params) ->
		super params

	eco: ->
		'ship'

	ship: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # 点击了 [已发货] 按键
				@params.order.stateid = 11 # 等待客户收货
				@params.order.save()
				@navigate('/orders',@params.order.id,'show')
			else if i is 1 # 查看合同
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")

		catch err
			@log err
		finally
			Order.url = oldUrl

# 等待客户收货
class orderReceive extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'receive'
  
	constructor: (params) ->
		super params

	eco: ->
		'receive'

	receive: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # 点击了 [已收货] 按键
				@params.order.stateid = if @params.order.guarantee > 0 then 12 else 13
			else if i is 1 # 查看合同
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')

		catch err
			@log err
		finally
			Order.url = oldUrl

# 等待客户支付质保金
class orderQA extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'qa'
  
	constructor: (params) ->
		super params

	eco: ->
		'qa'

	qa: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # 点击了 [已支付] 按键
				@params.order.stateid = 13 # 完成
			else if i is 1 # 查看合同
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')

		catch err
			@log err
		finally
			Order.url = oldUrl

class CurrentState extends Spine.Controller
	className: 'currentstate'
  
	constructor: ->
		super

		@active @change

		@order = $.Deferred()
		@orderstate = $.Deferred()

		Order.bind "refresh",=>@order.resolve()
		Orderstate.bind "refresh",=>@orderstate.resolve()

		Spine.bind "transportchange",(carriagecharge) =>
			@item.order.carriagecharge = parseFloat carriagecharge

		Spine.bind "paymentchange",(ainput)=>  # 绑定定金、质保金、质保期改变处理程序
			@item.order[ainput.attr("name")] = parseInt ainput.val()
  
	render: =>
		@html require("views/stateorder#{@eco}")(@item)
	
	change: (params) =>
		try
			$.when( @order,@orderstate).done =>
				if Order.exists params.id
					order = Order.find params.id
					@item = 
						order:order
						state:Orderstate.find order.stateid
					mode = params.match[0].substr(-4)
					if mode is 'edit'
						state = switch parseInt order.stateid
							when 1
								new orderCheck el:@el,order:order
							when 2
								new orderPrint el:@el,order:order
							when 3
								new orderAdvance el:@el,order:order
							when 4,5,6,7,8
								new orderReturned el:@el,order:order
							when 9
								new orderPayment el:@el,order:order
							when 10
								new orderShip el:@el,order:order
							when 11
								new orderReceive el:@el,order:order
							when 12
								new orderQA el:@el,order:order
					else
						state = new manageOrder el:@el,order:order
					@eco = state.eco()
					@render()
		catch err
			@log "file: sysadmin.order.current.coffee\nclass: CurrentState\nerror: #{err.message}"

module.exports = CurrentState