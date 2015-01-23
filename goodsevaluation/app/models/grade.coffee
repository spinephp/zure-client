Spine = require('spine')
Person = require('models/person')
require('spine/lib/ajax')

# 创建企业模型
class Grade extends Spine.Model
	@configure 'Grade', 'id',"names","image"

	@extend Spine.Model.Ajax

	@url: '? cmd=Grade'

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

module.exports = Grade
