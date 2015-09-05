Spine = require('spine')
require('spine/lib/ajax')
Goodclass = require('models/goodclass')

# 创增值税发票模型
class Good extends Spine.Model
	@configure 'Good', 'id','classid','size','picture'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Product'

	@fetch: (params) ->
		fields = @attributes
		condition = [{ field: 'homeshow',value: 'Y',operator:'eq' }]
		params or= 
			data:{filter: fields, cond:condition,token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	names:->
		item = Goodclass.find @classid
		item.names

	kindNames:->
		item = Goodclass.find @classid
		item.kindNames()

	longNames:->
		item = Goodclass.find @classid
		item.longNames()

module.exports = Good
