Spine = require('spine')
Person = require('models/person')
Department = require('models/department')
require('spine/lib/ajax')

# 创建企业模型
class Employee extends Spine.Model
	@configure 'Employee', 'id',"userid","departmentid","startdate","dateofbirth","myright"


	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Employee'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		@scope = "woo"
		super(params)

	getName:->
		result = ""
		if Person.exists parseInt @userid
			item = Person.find @userid
			result = item.name or item.username
		result

	getDepartment:->
		item = Department.find @departmentid
		item.name

module.exports = Employee
