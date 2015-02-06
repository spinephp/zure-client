Spine   = require('spine')
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
		Consignee.bind('refresh change', @address)
		Province.bind('refresh change', @address)
		City.bind('refresh change', @render)
		Zone.bind('refresh change', @render)
  
	render: =>
		try
			if City.count() and Zone.count()
				item = Consignee.first()
				pName = Province.find( item.province).name
				cName = Province.getCityName ""+item.province+item.city
				zName = Province.getZoneName ""+item.province+item.city+item.zone
				@html require('views/showconsignee')({receipt:{
					'收货人': item.name
					'地址': pName+cName+zName+item.address
					'固定电话': item.tel
					'手机号码': item.mobile
					'电子邮件': item.email
				}})
		catch err
			console.log "file: orderdetail.consignee.coffee, error: #{err.message}"

	change: (params) =>
		@render()

	address:->
		if Consignee.count() and Province.count()
			item = Consignee.first()
			Province.getCity(item.province)
			Province.getCity(""+item.province+item.city)

    
module.exports =  Receivers