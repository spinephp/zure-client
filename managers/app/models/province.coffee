Spine = require('spine')
City = require('models/city')
Zone = require('models/zone')

# ���վ�ģ��
class Province extends Spine.Model
	@configure 'Province', 'id', 'name'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Province'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

	@ajaxCity:(url,data,async,process)->
		jQuery.ajax
			type: 'get'
			url: url
			data: data
			async: async   #ajaxִ����Ϻ��ִ�к���ָ��
			success: (result) ->
				obj = JSON.parse(result)
				if typeof (obj) is "object"
					process?(obj)

	# ����ʡ(��)����ȡ��Ӧ��ʡϽ��(��Ͻ����),���ѽ�������Ӧ������ģ����
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
			token = sessionStorage.token
			data =  filter: filter,cond:cond, token:token 
			@ajaxCity url,data,off,(obj)->
				for rec in obj
					item = new Area rec
					item.save()
		Area.select (item)-> item.id > minval and item.id < maxval

	# �����б���ȡ����
	@getCityName:(cityid) ->
		@getCity cityid[0..1]
		City.find(cityid).name

	# ������������ȡ������
	@getZoneName:(zoneid) ->
		@getCity zoneid[0..3]
		Zone.find(zoneid).name

module.exports = Province
