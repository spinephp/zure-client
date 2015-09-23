Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

class DepartmentDeletes extends Spine.Controller
	className: 'departmentdeletes'
  
	elements:
		'form':'formEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@department = $.Deferred()
		@url = Department.url
		Department.bind "refresh",=>@department.resolve()
  
	render: ->
		@html require("views/departmentdelete")(@item)
		$("body >header h2").text "劳资管理->员工管理->删除部门"
	
	change: (params) =>
		try
			$.when( @department).done =>
				if Department.exists params.id
					@item = 
						department:Department.find params.id
					@render()
		catch err
			@log "file: sysadmin.main.employee.option.departmentdelete.coffee\nclass: DepartmentDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		$.fn.makeDeleteParam @formEl,Department
		@item.department.destroy() if confirm("确实要删除部门 [#{@item.department.name}] 吗?")

module.exports = DepartmentDeletes