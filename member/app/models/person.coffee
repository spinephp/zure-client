Spine = require('spine')
require('spine/lib/ajax')

# ������ҵģ��
class Person extends Spine.Model
	@configure 'Person', 'id',"username","nick","name","sex","mobile","tel","email","qq","county","address","companyid","identitycard","picture","lasttime"

	@extend Spine.Model.Ajax

	@url: '? cmd=Person'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"id",value:'?userid',operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Person