Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

class AddEmployees extends Spine.Controller
	className: 'addemployees'

	elements:
		'form':"formEl"
		'input[name=UserName]':"usernameEl"
		'#username_err_info':"usernameerrEl"
  
	events:
		'click button':'checkUsername'
		'click form input[type=submit]':'formSubmit'
  
	constructor: ->
		super
		@active @change
		#@token = $.fn.cookie "PHPSESSID"

	render: ->
		@html require("views/fmaddemployees")(@item)
		
	change: (params) =>
		try
			@item = 
				departments:Department.all()
			@render()
		catch err
			@log "file: sysadmin.addemployee.coffee\nclass: AddEmployees\nerror: #{err.message}"

	validateUserName:(username)->
		if /^[a-zA-Z]{1}[a-zA-Z0-9\-\_\@\.]{4,16}[a-zA-Z0-9]{1}$/.test(username)
			#用户名不能以数字开头
			return 1
		else
			return 0

	# AJAX 检查用户名是否存在，如用户名存在，用绿色在 username_err_info 指定处显示"通过"，
	# 否则用红色在 username_err_info 指定处显示"用户名已存在"或其它错误信息。
	# @param string value - 包含用户名的字符串
	checkUserName:(value)->
		param = $.param({filter:["username"], cond: [{ field:"username",value:value,operator:"eq" }], token: sessionStorage.token })
		url = "? cmd=Person&" + param
		$.getJSON url, null, (result) ->
			clTxt = "red"
			if result instanceof Array
				if result.length is 0
					info = "通过"
					clTxt = "green"
				else
					info = "用户名已存在"
			else 
				info = result
			$("#username_err_info").html(info).css("color",clTxt)

	checkUsername:(e)->
		value = $(@usernameEl).val()
		ret = validateUserName(value)
		checkUserName(value) if ret is 1
		
	formSubmit:(e)->
		e.preventDefault()
		e.stopPropagation()
		$.ajax
			url: "? cmd=UserRegister" # 提交的页面
			data: $(@formEl).serialize() # 从表单中获取数据
			type: "POST" # 设置请求类型为"POST"，默认为"GET"
			beforeSend: -> # 设置表单提交前方法
			   # new screenClass().lock();
			error: (request) -> # 设置表单提交出错
				alert "表单提交出错，请稍候再试"
			success: (data) ->
				obj = JSON.parse(data)
				alert("恭喜您，"+obj.register+"\n\n"+obj.email)
				@navigate '/members/employee'

module.exports = AddEmployees