# description: 省市区三级(二级)联动
Province = require('models/province')


citySelector = do ->
	Init:(address, pre, hasDistrict) ->
		initProvince = "<option value='0'>请选择省份</option>"
		initCity = "<option value='0'>请选择城市</option>"
		initDistrict = "<option value='0'>请选择区县</option>"

		@_LoadOptions(Province.all(), pre[0], address.eq(0), null, 0, initProvince)
		address.eq(0).change => 
			@_LoadOptions(Province.getCity(address.eq(0).val()), pre[1],address.eq(1), address.eq(0), 2, initCity)
		if hasDistrict
			address.eq(1).change => 
				@_LoadOptions(Province.getCity(address.eq(1).val()), pre[2], address.eq(2), address.eq(1), 4, initDistrict)
			address.eq(0).change -> address.eq(1).change()
		setTimeout ( -> address.eq(0).change()) ,100

	_LoadOptions:(items, preobj, targetobj, parentobj, comparelen, initoption)  ->
		t = ''# html容器 
		pre = preobj || 0    # pre:  初始值
		for item in items
			s = ''
			if comparelen is 0
				if pre isnt "" && pre isnt 0 && item.id is pre
					s = ' selected=\"selected\" '
					pre = ''
				t += '<option value=' + item.id + s + '>' + item.name + '</option>'
			else 
				p = parentobj.val()
				if p.substring(0, comparelen) is item.id.substring(0, comparelen)
					if pre isnt "" && pre isnt 0 && item.id is pre
						s = ' selected=\"selected\" '
						pre = ''
					t += '<option value=' + item.id + s + '>' + item.name + '</option>'

		targetobj.html(initoption + t)

module.exports = citySelector