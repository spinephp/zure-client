Spine	= require('spine')
Right = require('models/right')
Employee = require('models/employee')

$		= Spine.$

class EmployeeRights extends Spine.Controller
	className: 'employeerights'

	constructor: ->
		super
		@token = $.fn.cookie('PHPSESSID')
		@active @change

		@employee = $.Deferred()
		Employee.bind "refresh",=>@employee.resolve()
		@right = $.Deferred()
		Right.bind "refresh",=>@right.resolve()
		
		Spine.bind "userlogined",(item)->
			Right.fetch() if item.state & parseInt "0x00002000",16
  
	render: ->
		@html require("views/fmemployeerights")(@item)
	
	change: (params) =>
		try
			$.when( @employee,@right).done =>
				if Employee.exists params.id
					employee = Employee.find params.id
				else
					employee = new Employee
				@item =
					employees:employee
					rights: Right.all() if Right.count() > 0
				@render()
		catch err
			@log "file: sysadmin.employee.right.coffee\nclass: EmployeeRights\nerror: #{err.message}"

module.exports = EmployeeRights