Spine   = require('spine')
Currency = require('models/currency')
Default = require('models/default')
Order = require('models/order')
Transport = require('models/transport')
$       = Spine.$

class Transports extends Spine.Controller
	className: 'transports'
  
	constructor: ->
		super
		@active @change
		
		@currency = $.Deferred()
		@default = $.Deferred()
		@order= $.Deferred()
		@transport = $.Deferred()
		Currency.bind "refresh",=>@currency.resolve()
		Default.bind "refresh",=>@default.resolve()
		Order.bind "refresh",=>@order.resolve()
		Transport.bind "refresh",=>@transport.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@item.currency = Currency.find @item.default.currencyid
				@render()
   
	render: =>
		@html require('views/showtransport') @item
    
	change: (params) =>
		try
			$.when(@order,@transport,@currency,@default).done =>
				default1 = Default.first()
				theOrder = Order.find $.getUrlParam "orderid"
				transport = Transport.find theOrder.transportid
				currency = Currency.find default1.currencyid
				@item = 
					default:default1
					orders:theOrder
					transports:transport
					currencys:currency
				@render()
		catch err
			@log "file:ordertetail.product.coffee\nclass:Products\nerror: #{err.message}"
    
module.exports =  Transports