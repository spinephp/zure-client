Spine	= require('spine')
Employee = require('models/employee')
Person = require('models/person')
Department = require('models/department')

$		= Spine.$

class EmployeeDeletes extends Spine.Controller
	className: 'employeedeletes'
  
	elements:
		'form':'formEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@employee = $.Deferred()
		@url = Employee.url
		Employee.bind "refresh",=>@employee.resolve()
  
	render: ->
		@html require("views/employeedelete")(@item)
		$("body >header h2").text "劳资管理->员工管理->删除员工"
	
	change: (params) =>
		try
			$.when( @employee).done =>
				if Employee.exists params.id
					employee = Employee.find params.id
					@item = 
						employee:employee
						person:Person.find employee.userid
						department:Department.find employee.departmentid
					@render()
		catch err
			@log "file: sysadmin.main.employee.option.classdelete.coffee\nclass: EmployeeDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		key = $(@formEl).serializeArray()
		Employee.one "beforeDestroy", =>
			Employee.url = "woo/"+Employee.url if Employee.url.indexOf("woo/") is -1
			Employee.url += "&token="+ $.fn.cookie('PHPSESSID') unless Employee.url.match /token/
			Employee.url += "&#{field.name}=#{field.value}" for field in key when not Employee.url.match "&#{field.name}="

		Employee.one "ajaxSuccess", (status, xhr) => 
			Employee.url = @url
			@item.person.destroy ajax:false

		@item.employee.destroy() if confirm("确实要删除员工 #{@item.employee.getName()} 吗?")

module.exports = EmployeeDeletes