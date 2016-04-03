Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Person extends Spine.Model
	@configure 'Person', 'id',"username","nick","name","sex","mobile","tel","email","qq","country","county","address","companyid","identitycard","picture","lasttime"

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Person'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"id",value:'?userid',operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Person
