Spine   = require('spine')
Default = require('models/default')
Order = require('models/order')
Consignee = require('models/consignee')
Province = require('models/province')
City = require('models/city')
Zone = require('models/zone')
$       = Spine.$

class Receivers extends Spine.Controller
	className: 'receivers'
    
	elements: 
		'dl dt span': 'editEl'
  
	constructor: ->
		super
		@active @change
		
		@default= $.Deferred()
		@city = $.Deferred()
		@zone = $.Deferred()
		
		Default.bind "refresh",=>@default.resolve()
		City.bind "refresh",=>@city.resolve()
		Zone.bind "refresh",=>@zone.resolve()
				
		Order.bind "refresh",@address
		Consignee.bind "refresh",@address
		Province.bind "refresh",@address

		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
				
	render: =>
		@html require('views/showconsignee') @item

	change: (params) =>
		try
			$.when(@city,@zone,@default).done =>
				default1 = Default.first()
				pName = Province.find( @consignee.province).name
				cName = Province.getCityName ""+@consignee.province+@consignee.city
				zName = Province.getZoneName ""+@consignee.province+@consignee.city+@consignee.zone
				@item = 
					default:default1
					consignees:@consignee
					provinces:Province
					receipt:
						'Consignee': default1.toPinyin @consignee.name
						'Address': default1.address(pName,cName,zName,@consignee.address)
						'Tel': @consignee.tel
						'Mobile': @consignee.mobile
						'Email': @consignee.email
				@render()
		catch err
			@log "file:ordertetail.product.coffee\nclass:Products\nerror: #{err.message}"
    
	address:=>
		if Order.count() and Consignee.count() and Province.count()
			theOrder = Order.find $.fn.getUrlParam "orderid"
			@consignee = Consignee.find theOrder.consigneeid
			Province.getCity(@consignee.province)
			Province.getCity ""+@consignee.province+@consignee.city
module.exports =  Receivers