Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

class DepartmentAdds extends Spine.Controller
	className: 'departmentadds'
  
	elements:
		"button":"buttonEl"
		'form':'formEl'
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
		'input[name=code]':'verifyEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@token = $.fn.cookie('PHPSESSID')
		@active @change

		@department = $.Deferred()
		
		Department.bind "refresh",=>@department.resolve()
  
	render: ->
		@html require("views/fmdepartment")(@item)
		$("body >header h2").text "劳资管理->员工管理->添加部门"
	
	change: (params) =>
		try
			$.when(@department).done =>
				@item = 
					department:new Department
				@render()
		catch err
			@log "file: sysadmin.main.employee.option.departmentedit.coffee\nclass: DepartmentEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)->
		e.preventDefault()
		item = {department:{}}
		$.fn.makeRequestParam @formEl,item,['D_']
		item['action'] = 'department_create'
		
		param = JSON.stringify(item)
		url = Department.url.substr 4
		$.ajax
			url: url # 提交的页面
			data: param
			type: "POST" # 设置请求类型为"POST"，默认为"GET"
			dataType: "json"
			beforeSend: -> # 设置表单提交前方法
				# new screenClass().lock();
			error: (request)->       # 设置表单提交出错
				#new screenClass().unlock();
				alert("表单提交出错，请稍候再试")
			success: (data) =>
				#obj = JSON.parse(data)
				if data.id > -1
					alert "数据保存成功！"
					@item.department.updateAttributes data.department,ajax: false
					Department.trigger "create",@item.department
					#@navigate('/department/',data.id,'show') 
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							$(".validate").click()
							$(@verifyEl).focus()


module.exports = DepartmentAdds