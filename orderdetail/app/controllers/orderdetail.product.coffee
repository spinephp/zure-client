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
		Product.bind('refresh change', @render)
 
	render: =>
		try
			if Product.count() and Order.count()
				order = Order.first()
				console.log order
				product = Product.all()
				@html require('views/showorder')({orders:order,products:product})
		catch err
			console.log "9999"+err.message
    
	change: (params) =>
		@render()
    
module.exports = Products