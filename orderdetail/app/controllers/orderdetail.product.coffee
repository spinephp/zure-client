Spine   = require('spine')
Product   = require('models/orderproducts')
Order   = require('models/order')
$       = Spine.$

class Products extends Spine.Controller
	className: 'products'
  
	constructor: ->
		super
		@active @change
		Order.bind('refresh change', -> Product.fetch())
		Product.bind('refresh change', @change)
 
	render: =>
		@html require('views/showorder')(@item)
    
	change: (params) =>
		try
			if Product.count() and Order.count()
				order = Order.first()
				@item = 
					orders:order
					products:Product
				@render()
		catch err
			console.log "9999"+err.message
    
module.exports = Products