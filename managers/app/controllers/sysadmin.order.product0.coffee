Spine   = require('spine')
Product   = require('models/orderproducts')
Order   = require('models/order')
$       = Spine.$
Transports = require('controllers/sysadmin.order.transport')
Payments = require('controllers/sysadmin.order.payment')

class OrderProductShow extends Spine.Controller
	className: 'orderproductshow'

	events:
		"click button":"back"
  
	constructor: ->
		super
		@active @change
		Order.bind('refresh change', -> Product.fetch())
		Product.bind('refresh change', @render)

	render: =>
		try
			if Product.count() and @order
				@html require('views/orderproducts0')({orders:@order,products:Product})
		catch err
			@log "file: sysadmin.order.product.coffee\nclass: OrderProducts\nerror: #{err.message}"
	
	change: (params) =>
		@order = Order.find params.id
		@render()

	back: (e) => # 绑定返回处理程序
		oldUrl = Order.url
	
module.exports = OrderProductShow