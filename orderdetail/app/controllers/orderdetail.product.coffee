Spine   = require('spine')
Currency = require('models/currency')
Default = require('models/default')
Product   = require('models/orderproducts')
Order   = require('models/order')
$       = Spine.$

class Products extends Spine.Controller
	className: 'products'
  
	constructor: ->
		super
		@active @change
		
		@currency = $.Deferred()
		@default = $.Deferred()
		@order= $.Deferred()
		@goods = $.Deferred()
		Currency.bind "refresh",=>@currency.resolve()
		Default.bind "refresh",=>@default.resolve()
		Order.bind "refresh",=>@order.resolve()
		Product.bind "refresh",=>@goods.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@item.currency = Currency.find @item.default.currencyid
				@render()
	render: =>
		@html require('views/showorder')(@item)
    
	change: (params) =>
		try
			$.when(@order,@goods,@currency,@default).done =>
				default1 = Default.first()
				theOrder = Order.find $.getUrlParam "orderid"
				@item = 
					default:default1
					orders:theOrder
					products:Product
				@render()
		catch err
			@log "file:ordertetail.product.coffee\nclass:Products\nerror: #{err.message}"
    
module.exports = Products