Spine   = require('spine')
Manager = require('spine/lib/manager')
$       = Spine.$
Department = require('models/department')
Employee = require('models/employee')
Person = require('models/person')

Option    = require('controllers/sysadmin.employee.option')
Tree = require('controllers/sysadmin.employee.tree')

class Employees extends Spine.Controller
	className: 'employees'
  
	constructor: ->
		super
			
		@tree = new Tree
		@option    = new Option

		Spine.bind "userlogined",(user)->
			Employee.one 'refresh',->
				Person.append (item.userid for  item in Employee.all() when not Person.exists item.userid)
			Department.fetch()
			Employee.fetch()

			
		@routes
			'/department/new': (params) -> 
				@active(params)
				#@tree.active params
				@option.departmentadd.active(params)
			'/department/:id/show': (params) -> 
				@active(params)
				@tree.active params if params.id is '1'
				@option.departmentshow.active(params)
			'/department/:id/edit': (params) -> 
				@active(params)
				#@tree.active params
				@option.departmentedit.active(params)
			'/department/:id/delete': (params) -> 
				@active(params)
				#@tree.active params
				@option.departmentdelete.active(params)
			'/employees/new': (params) -> 
				@active(params)
				#@tree.active params
				@option.employeeadd.active(params)
			'/employees/:id/show': (params) -> 
				@active(params)
				#@tree.active params
				@option.employeeshow.active(params)
			'/employees/:id/edit': (params) -> 
				@active(params)
				#@tree.active params
				@option.employeeedit.active(params)
			'/employees/:id/delete': (params) -> 
				@active(params)
				#@tree.active params
				@option.employeedelete.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		@navigate('/department',1,'show')
    
module.exports = Employees