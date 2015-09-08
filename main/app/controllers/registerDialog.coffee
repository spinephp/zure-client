
registerDialog = ->
	__refactor__ = false #是否需要重新构建 该对话框
	open: (options)->
		$("#registDialog").remove() if __refactor__
		if $("#registDialog").size() > 0
			$("#registDialog").dialog("open")
			return

		char = options.defaults.translate 'Char'
		pin = options.defaults.translate 'Enter char in box'
		ckPin = options.defaults.translate 'Click get another pin'
		exp = options.defaults.translate 'e.g.'
		ditto = options.defaults.translate 'Ditto'
		html = "<div id='registDialog'>"
		html += "<form id='fmUserRegister'>"
		html += "<dl>"
		html += "<dt><label for='UserName'>#{options.defaults.translate 'Name'}:</label></dt><dd><input name='UserName' type='text' required placeholder='6~18 #{char}(a-zA-Z0-9.-_@)' /></dd><dd><span>*</span> <span id='username_rule'><button id='verifyUserName'>#{options.defaults.translate 'Verify'}</button> </span><span id='username_err_info'></span></dd>"
		html += "<dt><label for='Password'>#{options.defaults.translate 'PWD'}:</label></dt><dd><input name='Password' type='password' required placeholder='6-16 #{char}(a-zA-Z0-9.!@#$%^&*?_~)'/></dd><dd><span>*</span><span id='password_err_info'></span></dd>"
		html += "<dt><label >#{options.defaults.translate 'Strength'}:</label></dt><dd id='password_label' style='width:245px;border:1px solid #ccc;margin-top:3px;'><span style='width:150px;height:20px;display:block;border:1px solid #F0F0F0'> </span></dd>"
		html += "<dt><label for='PasswordAgain'>#{options.defaults.translate 'RE-PWD'}:</label></dt><dd><input name='PasswordAgain' type='password' required placeholder='#{ditto}'/></dd><dd><span>*</span><span id='passwordagain_err_info'></span></dd>"
		html += "<dt><label for='Email'>#{options.defaults.translate 'Email'}:</label></dt><dd><input name='Email' type='email' required placeholder='#{exp}:abc@example.com'/></dd><dd><span>*</span><span id='email_err_info'></span></dd>"
		html += "<dt><label for='Mobile'>#{options.defaults.translate 'Mobile'}:</label></dt><dd><input name='Mobile' type='text' placeholder='#{exp}:18961376627' /></dd><dd><span>*</span><span id='mobile_err_info'></span></dd>"
		html += "<dt><label for='Tel'>#{options.defaults.translate 'Tel'}:</label></dt><dd><input name='Tel' type='tel' required placeholder='#{exp}:+86 518 82340137'/></dd><dd><span>*</span><span id='tel_err_info'></span></dd>"
		html += "<dt><label for='Validate'>#{options.defaults.translate 'PID'}:</label></dt><dd><input name='code' type='text' required placeholder='#{pin}' /></dd><dd><span>* </span><img id='validate' src='admin/checkNum_session.php' align='absmiddle' style='border:#CCCCCC 1px solid; cursor:pointer;' alt='#{ckPin}' width=50 height=20 /></dd>"
		html += "</dl>"
		html += "<input type='hidden' name='action' value='custom_register' />"
		html += "<input type='hidden' name='LastTime' value='' />"
		html += "<input type='hidden' name='Times' value='0' />"
		html += "<input type='hidden' name='token' value=" + sessionStorage.token + " />"
		html += "</form>"
		html += "</div>"

		$(html).appendTo("body")
		
		$("#validate").attr('title', "#{options.defaults.translate 'Click get another pin'}")

		$("#fmUserRegister input[name=Password]").keyup ()->
			registerDialog().checkpass($(this).val(), $("#fmUserRegister input[name=UserName]").val())

		# 用户名检测按键处理程序
		$("#verifyUserName").click ()=>
			value = $("#fmUserRegister input[name=UserName]").val()
			ret = registerDialog().validateUserName(value)
			if ret is 1
				registerDialog().checkUserName(value)
		
		# 用户注册表输入框获得焦点时处理程序
		$("#fmUserRegister dl").delegate "dd input","focus",()->
			name = $(this).attr("name")
			value = $(this).val()
			basename = name.substr(6).toLowerCase()
			errinfo = $("#" + basename + "_err_info")
			errinfo.hide() if errinfo? 
			return false

		$("#validate").click ()->
			this.src="admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)

		# 用户注册表输入框失去焦点时处理程序
		$("#fmUserRegister dl").delegate "dd input","blur",()->
			name = $(this).attr("name")
			value = $(this).val()
			errUserName = ["用户名不能为空", "用户名不能以数字开头", "合法长度为6-18个字符", "用户名只能包含_,英文字母,数字 ", "用户名只能英文字母或数字结尾"]
			basename = name.toLowerCase()
			errinfo = $("#" + basename + "_err_info")
			ret
			info
			errinfo.show() if errinfo 
			pass = options.defaults.translate 'Pass'
			switch basename
				when "username"
					ret = registerDialog().validateUserName(value)
					if ret is 1 # AJAX 查询用户名是否存在
						registerDialog().checkUserName(value)
						return true
					else # 显示用户名输入框错误信息
						info = "Invalid user name"
				when "password","passwordagain"
					info = if /^[\w\-\!\@\#\$\%\^\&\*]{6,16}$/.test(value) then "Pass" else "Password format error"
				when "email"
					info = if /^\w+((-\w+)|(\.\w+))*\@\w+((\.|-)\w+)*\.\w+$/.test(value) then "Pass" else "Email format error"
				when "mobile"
					info = if /^1[3|4|5|8]\d{9}$/.test(value) then "Pass" else "Invalid phone number"
				when "tel"
					info = if /^((\+\d{2,3}[ |-]?)|0)\d{2,3}[ |-]?\d{7,9}$/.test(value) then "Pass" else "Invalid telephone number"
			info = options.defaults.translate info
			errinfo.css("color",(if info is pass then "green" else "red"))
			errinfo.html(info)
			if info isnt pass
				$(this).focus()
				return false

		$("#registDialog").dialog
			autoOpen: false
			closeOnEscape: true
			width: '600px'
			modal: true
			title: options.defaults.translate 'Custom register'
			buttons: 
				"Sign up": () ->
					__refactor__ = true
					pwd1 = $("#fmUserRegister input[name=Password]")
					pwd2 = $("#fmUserRegister input[name=PasswordAgain]")
					if pwd1.val() isnt pwd2.val()
						alert("分别键入的两个密码不一致!\n请重新输入。")
						pwd1.val("")
						pwd2.val("")
						pwd1.focus()
						return false
					
					jQuery.ajax
						url: "? cmd=UserRegister&token="+$.fn.cookie "PHPSESSID"   # 提交的页面
						data: $('#fmUserRegister').serialize() # 从表单中获取数据
						type: "POST"                   # 设置请求类型为"POST"，默认为"GET"
						beforeSend: ()->         # 设置表单提交前方法
						   # new screenClass().lock();
						error: (request)->      # 设置表单提交出错
							#new screenClass().unlock()
							alert("表单提交出错，请稍候再试")
						success: (data)->
							obj = JSON.parse(data)
							#new screenClass().unlock(); # 设置表单提交完成使用方法
							$("#registDialog").dialog("close")
							alert("恭喜您，"+obj.register+"\n\n"+obj.email)
				"Close": () ->
					$("#registDialog").dialog("close")
			open:->
				# 翻译按钮文本
				btns =  $(@).next().find('button span')
				$(btn).text options.defaults.translate $(btn).text() for btn in btns
				
		$("#registDialog").dialog("open");
		__refactor__ = false;

	validateUserName:(username)->
		if /^[a-zA-Z]{1}[a-zA-Z0-9\-\_\@\.]{4,16}[a-zA-Z0-9]{1}$/.test(username)
			#用户名不能以数字开头
			return 1
		else
			return 0

	# AJAX 检查用户名是否存在，如用户名存在，用绿色在 username_err_info 指定处显示"通过"，
	# 否则用红色在 username_err_info 指定处显示"用户名已存在"或其它错误信息。
	# @param string value - 包含用户名的字符串
	#
	checkUserName:(value)->
		param = $.param({filter:["id","username"], cond: [{ field:"username",value:value,operator:"eq" }], token: sessionStorage.token })
		url = "? cmd=Person&" + param
		$.getJSON url, null, (result)->
			clTxt = "red"
			if result instanceof Array
				if result.length is 0
					info = "通过"
					clTxt = "green"
				else
					info = "用户名已存在"
			else
				info = result
			$("#username_err_info").css("color",clTxt)
			$("#username_err_info").html(info)

	testpass:(password, username)->
		score = 0
		return -4 if password.length < 4 
		return -2 if typeof (username) isnt 'undefined' and password.toLowerCase() is username.toLowerCase() 
		score += password.length * 4
		score += (registerDialog().repeat(i, password).length - password.length) * 1 for i in [1..4]
		score += 5 if password.match /(.*[0-9].*[0-9].*[0-9])/
		score += 5 if password.match /(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/
		score += 10 if password.match /([a-z].*[A-Z])|([A-Z].*[a-z])/
		score += 15 if password.match( /([a-zA-Z])/) and password.match( /([0-9])/)
		score += 15 if password.match( /([!,@,#,$,%,^,&,*,?,_,~])/) and password.match( /([0-9])/)
		score += 15 if password.match( /([!,@,#,$,%,^,&,*,?,_,~])/) and password.match( /([a-zA-Z])/)
		score += 5 if password.match( /^\w+$/) or password.match( /^\d+$/)
		score = 0 if score < 0
		score = 100 if score > 100
		score
	
	repeat:(len, str)->
		res = ""
		for i in [0...str.length]
			repeated = true
			max = str.length - i - len
			repeated = repeated && (str.charAt(j + i) is str.charAt(j + i + len)) for j in [0...len] when j < max
			repeated = false if j < len 
			if repeated
				i += len - 1
				repeated = false
			else 
				res += str.charAt(i)
		res

	checkpass:(pass,username)->
		user = username or "usrname"
		score = registerDialog().testpass pass, user
		password_label = $('#password_label')
		if score is -4
			password_label.html("<span style='height:20px;line-height:20px;display:block;'>太短</span>")
		else if score is -2
			password_label.html("<span style='height:20px;line-height:20px;display:block;'>与用户名相同</span>")
		else
			color = if score < 34 then'#edabab' else if score < 68 then '#ede3ab' else '#d3edab'
			text = if score < 34 then'弱' else if score < 68 then '一般' else '很好'
			width = score + '%';
			password_label.html("<span style='width:" + width + ";display:block;overflow:hidden;height:20px;line-height:20px;background:" + color + ";'>" + text + "</span>")

module.exports = registerDialog
