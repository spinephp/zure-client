Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

class AddEmployees extends Spine.Controller
	className: 'addemployees'

	elements:
		'form':"formEl"
		'input[name=UserName]':"usernameEl"
		'#username_err_info':"usernameerrEl"
		'input[name=pwd]':"psdEl"
		'input[name=PasswordAgain]':"psd1El"
		'div:first-child p:nth-child(3) span':'intensityEl'

		'form >div:last-child >img':"headshotimgEl"
		'.watermode img':"waterimgEl"
		'input[name=upload_head]':'fileheadEl'
		'input[name=upload_mask]':'filemaskEl'
		'.waterType':'watermaskEl'
		'.watermode':'watermodeEl'
  
	events:
		'keypress input[type=text]':'focusOption'
		'keypress input[type=password]':'focusOption'
		'keyup input[type=password]':'showIntensity'
		'blur input':'verifyValue'
		'click .validate':'verifyCode'
		'change input[name=upload_head]':'uploadHeadshot'
		'change input[name=upload_mask]':'uploadWatermask'
		'click .uploadimage >p button':'headshotClick'
		'click .watermode p button':'waterimageClick'
		'click input[name=watermask]': 'watermaskClick'
		'click input[name=watersel]': 'waterselClick'
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
				employees: new Employee
				persons: new Person
				departments:Department.all()
			@render()
		catch err
			@log "file: sysadmin.addemployee.coffee\nclass: AddEmployees\nerror: #{err.message}"

	validateUserName:(username)->
		if /^[a-zA-Z]{1}[a-zA-Z0-9\-\_\@\.]{4,16}[a-zA-Z0-9]{1}$/.test(username)
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
			$("#username_err_info").html(info).css("color",clTxt).show()
			if clTxt is "red"
				$(@usernameEl).focus() 
			else
				$(@usernameEl).next().focus() 

	testpass:(password, username)->
		score = 0
		return -4 if password.length < 4
		return -2 if username?.toLowerCase() is password?.toLowerCase()
		score += password.length * 4
		score += (@repeat(i, password).length - password.length) * 1 for i in [1..4]
		score += 5 if password.match(/(.*[0-9].*[0-9].*[0-9])/)
		score += 5 if password.match(/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/)
		score += 10 if password.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)
		score += 15 if password.match(/([a-zA-Z])/) and password.match(/([0-9])/)
		score += 15 if password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) and password.match(/([0-9])/)
		score += 15 if password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) and password.match(/([a-zA-Z])/)
		score -= 10 if password.match(/^\w+$/) or password.match(/^\d+$/)
		score = 0 if score < 0
		score = 100 if score > 100
		score
	
	repeat:(len, str)->
		res = ""
		for c,i in str
			repeated = true
			max = str.length - i - len
			min = Math.min(len,max)
			repeated = repeated and (str.charAt(j + i) is str.charAt(j + i + len)) for j in [0...min]
			repeated = false if j < len
			if repeated
				i += len - 1
				repeated = false
			else 
				res += str.charAt(i)
		res

	checkpass:(pass,username)->
		user = username or "username"
		score = @testpass(pass, user)
		intensity = $(@intensityEl)
		if score is -4
			intensity.text "太短"
		else if score is -2
			intensity.text "与用户名相同"
		else
			color = if score < 34 then '#edabab' else if score < 68  then '#ede3ab' else '#d3edab'
			text = if score < 34 then '弱' else if score < 68 then '一般' else '很好'
			width = score*2.25 + 'px'
			intensity.css('width', width).css('background',color).text(text)

	showIntensity:(e)->
		@checkpass($(e.target).val(), $(@usernameEl).val())

	focusOption:(e)->
		e.stopPropagation()
		name = $(e.target).attr("name")
		value = $(e.target).val()
		basename = name.toLowerCase()
		errinfo = $("#" + basename + "_err_info")
		errinfo?.hide()
		false

	verifyValue:(e)->
		name = $(e.target).attr("name")
		value = $(e.target).val()
		basename = name.toLowerCase()
		errinfo = $("#" + basename + "_err_info")
		info = "通过"
		color = "green"
		switch  basename
			when "username"
				ret = @validateUserName(value)
				if ret is 1 # AJAX 查询用户名是否存在
					@checkUserName(value)
					return false
				else # 显示用户名输入框错误信息
					info = "无效的用户名！"; 
			when "password","passwordagain"
				info = "密码格式错误" unless /^[\w\-\!\@\#\$\%\^\&\*]{6,16}$/.test(value)
			when "name"
				info = "姓名格式错误" unless /^[\u4e00-\u9fa5]{1,10}[·.]{0,1}[\u4e00-\u9fa5]{1,10}$/.test(value)
			when "email"
				info = "邮箱格式错误" unless /^\w+((-\w+)|(\.\w+))*\@\w+((\.|-)\w+)*\.\w+$/.test(value)
			when "mobile"
				info = "无效的手机号码" unless  /^1[3|4|5|8]\d{9}$/.test(value)
			when "tel"
				info = "无效的电话号码" unless /^((\+\d{2,3}[ |-]?)|0)\d{2,3}[ |-]?\d{7,9}$/.test(value)
			when "qq"
				info = "无效的qq号码" if value <10000 and value > 9999999999
		color = "red" unless info is "通过"
		errinfo.css("color",color).html(info).show()
		if info isnt "通过" 
			$(e.target).focus().select()
			return false

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	uploadFile:(key,file,img,path)->
		try
			throw 'File Size > 4M' if file.size > 4*1024*1024
			throw "Invalid File Type #{file.type}" unless file.type in ['image/jpg','image/jpeg','image/png','image/gif']
			formdata = new FormData()
			formdata.append(key, file)
			options = 
				type: 'POST'
				url: '? cmd=Upload&token='+@token
				data: formdata
				success:(result) =>
					img.attr 'src',path+result.image
					alert(result.msg)
				processData: false  # 告诉jQuery不要去处理发送的数据
				contentType: false   # 告诉jQuery不要去设置Content-Type请求头
				dataType:"json"
			$.ajax(options)
		catch error
			alert error

	uploadHeadshot:(e)->
		e.stopPropagation()
		@uploadFile 'userimg0',@fileheadEl[0].files[0],$(@headshotimgEl),'images/user/'

	uploadWatermask:(e)->
		e.stopPropagation()
		@uploadFile 'maskimg',@filemaskEl[0].files[0],$(@waterimgEl),'images/'

	headshotClick:(e)->
		e.preventDefault()
		e.stopPropagation()
		console.log @fileheadEl
		#$(@fileheadEl).click()

	waterimageClick:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@filemaskEl).click()
	
	watermaskClick:(e)->
		e.stopPropagation()
		display = if $(e.target).is(':checked') then 'block' else 'none'
		$(@watermaskEl).css 'display',display
		
	waterselClick:(e)->
		e.stopPropagation()
		$(@watermodeEl)
			.css('display','none')
			.eq($(e.target).val())
			.css 'display','block'

	formSubmit:(e)->
		e.preventDefault()
		e.stopPropagation()
		key = $(@formEl).serializeArray()
		item = {person:{},employee:{}}
		for field in key
			switch field.name[0..1]
				when 'P_'
					item.person[field.name[2..]] = field.value
				when 'E_'
					item.employee[field.name[2..]] = field.value
				else
					item[field.name] = field.value

		headshot = $(@headshotimgEl).attr 'src'
		name = headshot.replace 'images/user/',''
		item.person['picture'] = name if name isnt 'noimg.png'
		item.token = @token

		$.ajax
			url: "? cmd=Employee" # 提交的页面
			data: JSON.stringify(item) # 从表单中获取数据
			type: "POST" # 设置请求类型为"POST"，默认为"GET"
			beforeSend: -> # 设置表单提交前方法
			   # new screenClass().lock();
			error: (request) -> # 设置表单提交出错
				alert "表单提交出错，请稍候再试"
			success: (data) =>
				#obj = JSON.parse(data)
				if data.id isnt -1
					alert("恭喜您，员工"+item.person['name']+"添加成功!")
					@item.employees.updateAttributes data,ajax: false
					@navigate '/members/employee'

module.exports = AddEmployees