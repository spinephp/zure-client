Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

class DepartmentEdits extends Spine.Controller
	className: 'departmentedits'
  
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
		$("body >header h2").text "劳资管理->员工管理->编辑部门"
	
	change: (params) =>
		try
			$.when( @department).done =>
				if Department.exists params.id
					@item = 
						department:Department.find params.id
					@render()
		catch err
			@log "file: sysadmin.main.employee.option.classedit.coffee\nclass: DepartmentEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)->
		e.preventDefault()
		opt = $(e.target)
		key = $(@formEl).serializeArray()
		item = {department:{}}
		for field in key
			ckey = field.name[2..]
			cval = $.trim(field.value)
			if cval isnt ''
				switch field.name[0..1]
					when 'D_'
						item.department[ckey] = cval if cval isnt @item.department[ckey]
					else
						item[field.name] = cval
		item.token = @token

		param = JSON.stringify(item)

		@item.department.scope = 'woo'

		$.ajax
			url: @item.department.url() #"? cmd=ProductClass&token=#{@token}/"+@item.department.id # 提交的页面
			data: param
			type: "PUT" # 设置请求类型为"POST"，默认为"GET"
			dataType: "json"
			beforeSend: -> # 设置表单提交前方法
				# new screenClass().lock();
			error: (request)->       # 设置表单提交出错
				#new screenClass().unlock();
				alert("表单提交出错，请稍候再试")
			success: (data) =>
				if data.id > -1
					alert "数据保存成功！"
					@item.department.updateAttributes data.department,ajax: false
					Department.trigger "update",@item.department
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							$(".validate").click()
							$(@verifyEl).focus()


module.exports = DepartmentEdits