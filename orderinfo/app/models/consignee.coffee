Spine = require('spine')
require('spine/lib/ajax')
Province = require('models/province')

class Consignee extends Spine.Model
	@configure 'Consignee','id','name','province','city','zone','address','email','mobile','tel','postcard'
  
	@extend Spine.Model.Ajax
	@url:'? cmd=Consignee'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

	@current:null
        

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