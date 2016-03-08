Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

class DepartmentShows extends Spine.Controller
	className: 'departmentshows'
  
	constructor: ->
		super
		@active @change
		@department = $.Deferred()
		Department.bind "refresh",=>@department.resolve()
  
	render: ->
		@html require("views/department")(@item)
		$("body >header h2").text "劳资管理->员工管理->部门信息"
	
	change: (params) =>
		try
			$.when( @department).done =>
				if Department.exists params.id
					@item = 
						department:Department.find params.id
					@render()
		catch err
			@log "file: sysadmin.main.employee.option.departmentshow.coffee\nclass: DepartmentShows\nerror: #{err.message}"

	getItem:->
		@item

module.exports = DepartmentShows