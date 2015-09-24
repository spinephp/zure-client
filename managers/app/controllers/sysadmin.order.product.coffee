Spine   = require('spine')
Product   = require('models/orderproducts')
Order   = require('models/order')
$       = Spine.$

class OrderProducts extends Spine.Controller
	className: 'orderproducts'

	elements:
		"button":"buttons"
		"span.form_hint":"numberEl"

	events:
		"change input[name=returnnow]":"returnnow"
		"change input[name=modlcharge]":"modlcharge"
		"change input[name=shipdate]":"shipdate"
		"click button":"pass"
		"click tbody tr td:nth-child(4)":"shownumbers"
  
	constructor: ->
		super
		@active @change

		@product = $.Deferred()

		Order.bind "refresh",=>Product.fetch()
		Product.bind "refresh",=>@product.resolve()

		# 绑定运费改变处理程序
		Spine.bind "transportchange",(carriagecharge) =>
			@item.orders.carriagecharge = parseFloat carriagecharge
			@render()
			return false

		# 绑定定金、质保金、质保期改变处理程序
		Spine.bind "paymentchange",(ainput)=>
			@item.orders[ainput.attr("name")] = parseInt ainput.val()
			return false

	render: =>
		@html require('views/orderproducts'+@eco)(@item)
	
	change: (params) =>
		try
			$.when( @product).done =>
				if Order.exists params.id
					order = Order.find params.id
					@item = 
						orders:order
						products:Product
					@eco = params.match[0].substr(-4)
					@render()
		catch err
			@log "file: sysadmin.order.product.coffee\nclass: OrderProducts\nerror: #{err.message}"

	updateOrderproduct:(e,target)=>
		proid = parseInt( $(e.target).parent().parent().attr("data-product"),10)
		rmb = parseFloat $(e.target).val()
		item[target] = rmb for item in @item.orders.products when parseInt(item.proid,10) is proid
		@render()

	returnnow: (e) => # 绑定产品返现改变处理程序
		@updateOrderproduct e,'returnnow'

	modlcharge: (e) => # 绑定产品模具费用改变处理程序
		@updateOrderproduct e,'modlcharge'

	shipdate: (e) => # 绑定交货期改变处理程序
		@item.orders.shipdate = $(e.target).val()
		
	shownumbers:(e)->
		if $(@numberEl).css("display") is "block"
			$(@numberEl).css "display","none"
		else
			$(@numberEl).css "display","block"
		false
		
	pass: (e) => # 绑定 “审核通过”或 “取消订单” 处理程序
		oldUrl = Order.url
		try
			Order.bind "beforeUpdate", ->
				Order.url = "woo/index.php"+Order.url if Order.url.indexOf("woo/index.php") is -1
			i = @buttons.index e.target
			@item.orders.stateid = if i is 0 then 2 else 14

			@item.orders.save()
			@navigate('/sysadmins/order')
		catch err
			@log err
		finally
			Order.url = oldUrl
	
module.exports = OrderProducts