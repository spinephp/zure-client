
registerDialog = ->
	__refactor__ = true #是否需要重新构建 该对话框
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
		html += "<dt><label for='UserName'>#{options.defaults.translate 'Name'}:</label></dt><dd><input name='P_username' type='text' required placeholder='6~18 #{char}(a-zA-Z0-9.-_@)' /></dd><dd><span>*</span> <span id='username_rule'><button id='verifyUserName'>#{options.defaults.translate 'Verify'}</button> </span><span id='p_username_err_info'></span></dd>"
		html += "<dt><label for='Password'>#{options.defaults.translate 'PWD'}:</label></dt><dd><input name='P_pwd' type='password' required placeholder='6-16 #{char}(a-zA-Z0-9.!@#$%^&*?_~)'/></dd><dd><span>*</span><span id='p_pwd_err_info'></span></dd>"
		html += "<dt><label >#{options.defaults.translate 'Strength'}:</label></dt><dd id='password_label' style='width:245px;border:1px solid #ccc;margin-top:3px;'><span style='width:150px;height:20px;display:block;border:1px solid #F0F0F0'> </span></dd>"
		html += "<dt><label for='PasswordAgain'>#{options.defaults.translate 'RE-PWD'}:</label></dt><dd><input name='PasswordAgain' type='password' required placeholder='#{ditto}'/></dd><dd><span>*</span><span id='passwordagain_err_info'></span></dd>"
		html += "<dt><label for='Email'>#{options.defaults.translate 'Email'}:</label></dt><dd><input name='P_email' type='email' required placeholder='#{exp}:abc@example.com'/></dd><dd><span>*</span><span id='p_email_err_info'></span></dd>"
		html += "<dt><label for='Mobile'>#{options.defaults.translate 'Mobile'}:</label></dt><dd><input name='P_mobile' type='text' placeholder='#{exp}:18961376627' /></dd><dd><span>*</span><span id='p_mobile_err_info'></span></dd>"
		html += "<dt><label for='Tel'>#{options.defaults.translate 'Tel'}:</label></dt><dd><input name='P_tel' type='tel' required placeholder='#{exp}:+86 518 82340137'/></dd><dd><span>*</span><span id='p_tel_err_info'></span></dd>"
		html += "<dt><label for='Validate'>#{options.defaults.translate 'PIN'}:</label></dt><dd><input name='code' type='text' required placeholder='#{pin}' /></dd><dd><span>* </span><img id='validate' src='admin/checkNum_session.php' align='absmiddle' style='border:#CCCCCC 1px solid; cursor:pointer;' alt='#{ckPin}' width=50 height=20 /></dd>"
		html += "</dl>"
		html += "<input type='hidden' name='action' value='custom_create' />"
		html += "<input type='hidden' name='P_lasttime' value='' />"
		html += "<input type='hidden' name='P_times' value='0' />"
		html += "<input type='hidden' name='C_type' value='P' />"
		#html += "<input type='hidden' name='token' value=" + $.fn.cookie('PHPSESSIS') + " />"
		html += "</form>"
		html += "</div>"

		$(html).appendTo("body")
		
		$("#validate").attr('title', "#{options.defaults.translate 'Click get another pin'}")

		$("#fmUserRegister input[name=P_pwd]").keyup ()->
			registerDialog().checkpass($(this).val(), $("#fmUserRegister input[name=P_username]").val(),options)

		# 用户名检测按键处理程序
		$("#verifyUserName").click ()=>
			value = $("#fmUserRegister input[name=P_username]").val()
			ret = registerDialog().validateUserName(value)
			if ret is 1
				registerDialog().checkUserName(value,options)
		
		# 用户注册表输入框获得焦点时处理程序
		$("#fmUserRegister dl").delegate "dd input","focus",()->
			name = $(this).attr("name")
			value = $(this).val()
			basename = name.toLowerCase()
			errinfo = $("#" + basename + "_err_info")
			errinfo.hide() if errinfo? 
			return false

		$("#validate").click ()->
			this.src="admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)

		# 用户注册表输入框失去焦点时处理程序
		$("#fmUserRegister dl").delegate "dd input","blur",()->
			name = $(this).attr("name")
			value = $(this).val()
			errUserName = [
				"User name can not be empty"
				"User name cannot begin with a number"
				"Valid length 6-18 characters"
				"The user name can only contain _, English letters, numbers "
				"User name can only be the end of the English letters or numbers"
			]
			basename = name.toLowerCase()
			errinfo = $("#" + basename + "_err_info")
			errinfo.show() if errinfo 
			info = 'Pass'
			switch basename
				when "p_username"
					if registerDialog().validateUserName(value) is 1 # AJAX 查询用户名是否存在
						registerDialog().checkUserName(value,options)
						return true
					else # 显示用户名输入框错误信息
						info = "Invalid user name"
				when "p_pwd","passwordagain"
					info = if /^[\w\-\!\@\#\$\%\^\&\*]{6,16}$/.test(value) then "Pass" else "Password format error"
				when "p_email"
					info = if /^\w+((-\w+)|(\.\w+))*\@\w+((\.|-)\w+)*\.\w+$/.test(value) then "Pass" else "Email format error"
				when "p_mobile"
					info = if /^1[3|4|5|8]\d{9}$/.test(value) then "Pass" else "Invalid phone number"
				when "p_tel"
					info = if /^((\+\d{2,3}[ |-]?)|0)\d{2,3}[ |-]?\d{7,9}$/.test(value) then "Pass" else "Invalid telephone number"
			errinfo.css("color",(if info is 'Pass' then "green" else "red")).html(options.defaults.translate info)
			if info isnt 'Pass'
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
					pwd1 = $("#fmUserRegister input[name=P_pwd]")
					pwd2 = $("#fmUserRegister input[name=PasswordAgain]")
					if pwd1.val() isnt pwd2.val()
						alert options.defaults.translate "The two passwords you typed are not consistent. \n please re-enter."
						pwd2.val("")
						pwd1.val("").focus()
						$("#fmUserRegister input[name=P_pwd]").trigger "keyup"
						return false
						
					item = $.fn.makeRequestParam $("#fmUserRegister"),['custom','person'],['C_','P_']
					item['language'] = options.defaults.languageid-1;
					param = JSON.stringify(item)
					jQuery.ajax
						url: "? cmd=Custom&token="+$.fn.cookie "PHPSESSID"   # 提交的页面
						data: param # 从表单中获取数据
						type: "POST"                   # 设置请求类型为"POST"，默认为"GET"
						dataType: "json"
						beforeSend: ()->         # 设置表单提交前方法
						   # new screenClass().lock();
						error: (request)->      # 设置表单提交出错
							#new screenClass().unlock()
							alert options.defaults.translate "Error form submission, please try again later"
						success: (data)->
							if data.id > -1
								person = {}
								custom = {}
								person[item]=data.person[item] for item in options.Person.attributes
								custom[item]=data.custom[item] for item in options.Custom.attributes
								options.Person.refresh person,clear:false
								options.Custom.refresh custom,clear:false
								#@item.persons.updateAttributes person,ajax: false
								#@item.customs.updateAttributes custom,ajax: false
								$("#registDialog").dialog("close")
								alert options.defaults.translate("Congratulations,")+data.register+'\n'+data.email
							else
								switch data.error
									when "Access Denied"
										window.location.reload()
									when "Validate Code Error!"
										alert options.defaults.translate "Verify code error, please fill in."
										$("#validate").click()
										$("input[name=code]").focus()
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
	checkUserName:(value,options)=>
		param = $.param({filter:["id","username"], cond: [{ field:"username",value:value,operator:"eq" }], token: $.fn.cookie 'PHPSESSID' })
		url = "? cmd=Person&" + param
		$.getJSON url, null, (result)->
			clTxt = "red"
			if result instanceof Array
				if result.length is 0
					info = "Pass"
					clTxt = "green"
				else
					info = "User name already exists"
			else
				info = result
			$("#p_username_err_info").css("color",clTxt).html(options.defaults.translate info)

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

	checkpass:(pass,username,options)->
		user = username or "usrname"
		score = registerDialog().testpass pass, user
		password_label = $('#password_label')
		if score is -4
			password_label.html("<span style='height:20px;line-height:20px;display:block;'>"+options.defaults.translate('Short')+"</span>")
		else if score is -2
			password_label.html("<span style='height:20px;line-height:20px;display:block;'>"+options.defaults.translate('Same user name')+"</span>")
		else
			color = if score < 34 then'#edabab' else if score < 68 then '#ede3ab' else '#d3edab'
			text = if score < 34 then'Weak' else if score < 68 then 'General' else 'Very good'
			width = score + '%';
			password_label.html("<span style='width:" + width + ";display:block;overflow:hidden;height:20px;line-height:20px;background:" + color + ";'>" + options.defaults.translate(text) + "</span>")

module.exports = registerDialog
