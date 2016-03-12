Spine	= require('spine')
Employee = require('models/employee')
Person = require('models/person')
Department = require('models/department')

$		= Spine.$

class EmployeeShows extends Spine.Controller
	className: 'employeeshows'
  
	constructor: ->
		super
		@active @change
		@employee = $.Deferred()
		@department = $.Deferred()
		@person = $.Deferred()
		Department.bind "refresh",=>@department.resolve()
		Employee.bind "refresh",=>@employee.resolve()
		Person.bind "refresh",=>@person.resolve()
  
	render: ->
		@html require("views/employee")(@item)
	
	change: (params) =>
		try
			$.when(@employee,@person,@department).done =>
				if Employee.exists params.id
					employee = Employee.find params.id
					@item = 
						employee:employee
						person:Person.find employee.userid
						department:Department.find employee.departmentid
					@render()
		catch err
			@log "file: sysadmin.main.employee.option.classshow.coffee\nclass: EmployeeclassShows\nerror: #{err.message}"

	getItem:->
		@item

module.exports = EmployeeShows