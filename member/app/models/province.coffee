Spine = require('spine')
# 创收据模型
class City extends Spine.Model
	@configure 'City', 'id', 'name'

	@extend Spine.Model.Local

	@url: 'woo/index.php? cmd=City'

# 创收据模型
class Zone extends Spine.Model
	@configure 'Zone', 'id', 'name'

	@extend Spine.Model.Local

	@url: 'woo/index.php? cmd=District'

# 创收据模型
class Province extends Spine.Model
	@configure 'Province', 'id', 'name'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Province'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields,token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	@ajaxCity:(url,data,async,process)->
		jQuery.ajax
			type: 'get'
			url: url
			data: data
			async: async   #ajax执行完毕后才执行后续指令
			success: (result) ->
				obj = JSON.parse(result)
				if typeof (obj) is "object"
					process?(obj)

	# 根据省(市)编码取对应的省辖市(市辖县区),并把结果存入对应的数据模型中
	@getCity:(provinceid) ->
		return 0 if provinceid is 0  
		minval = provinceid+"00"
		maxval =  provinceid+"99"
		Area = if provinceid.length is 2 then City else Zone
		items = Area.select (item)-> item.id > minval and item.id < maxval
		if items.length is 0
			url = Area.url
			filter = ["id","name"]
			cond = [{field:"id",value:minval,operator:"ge"},{field:"id",value:maxval,operator:"le"}]
			token = $.fn.cookie 'PHPSESSID'
			data =  filter: filter,cond:cond, token:token 
			@ajaxCity url,data,off,(obj)->
				for rec in obj
					item = new Area rec
					item.save()
		Area.select (item)-> item.id > minval and item.id < maxval

	# 根据县区编码取县区名
	@getCityName:(cityid) ->
		@getCity cityid[0..1]
		City.find(cityid).name

	# 根据县区编码取县区名
	@getZoneName:(zoneid) ->
		@getCity zoneid[0..3]
		Zone.find(zoneid).name

module.exports = Province
