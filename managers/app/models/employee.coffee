Spine = require('spine')
Person = require('models/person')
Department = require('models/department')
require('spine/lib/ajax')

# 创建企业模型
class Employee extends Spine.Model
	@configure 'Employee', 'id',"userid","departmentid","startdate","dateofbirth","myright"


	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Employee'

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

	getDepartment:->
		item = Department.find @departmentid
		item.name

module.exports = Employee
