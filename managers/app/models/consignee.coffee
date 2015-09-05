Spine = require('spine')
require('spine/lib/ajax')
Order = require('models/order')
Province = require('models/province')

class Consignee extends Spine.Model
	@configure 'Consignee','id','name','country','province','city','zone','address','email','mobile','tel','postcard'
  
	@extend Spine.Model.Ajax
	@url:'woo/index.php? cmd=Consignee'

	@current:null

	@filter: (query) ->
		return @all() unless query
		query = query.toLowerCase()
		@select (item) ->
			item.name?.toLowerCase().indexOf(query) isnt -1 or
			item.email?.toLowerCase().indexOf(query) isnt -1
        

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current
		@current

	getAddressFirst: -> 
		@getProvinceName()+@getCityName()+@getZoneName()

	getProvinceName: () -> 
		Province.find(@province).name

	getCityName: () -> 
		Province.getCityName @province+@city

	getZoneName: () -> 
		Province.getZoneName @province+@city+@zone

module.exports = Consignee