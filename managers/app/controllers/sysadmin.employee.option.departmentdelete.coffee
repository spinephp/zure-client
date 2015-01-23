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
		key = $(@formEl).serializeArray()
		Department.one "beforeDestroy", =>
			Department.url = "woo/"+Department.url if Department.url.indexOf("woo/") is -1
			Department.url += "&token="+ $.fn.cookie('PHPSESSID') unless Department.url.match /token/
			Department.url += "&#{field.name}=#{field.value}" for field in key when not Department.url.match "&#{field.name}=" #存在问题是验证码不能更新

		Department.one "ajaxSuccess", (status, xhr) => 
			Department.url = @url
		@item.department.destroy() if confirm("确实要删除部门 [#{@item.department.name}] 吗?")

module.exports = DepartmentDeletes