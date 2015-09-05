Spine = require('spine')
Person = require('models/person')
require('spine/lib/ajax')

# 创建企业模型
class Custom extends Spine.Model
	@configure 'Custom', 'id',"userid","emailstate","mobilestate","accountstate","ip"


	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Custom'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	getName:->
		result = ""
		if Person.exists @userid
			item = Person.find @userid
			result = item.name
		result

module.exports = Custom
