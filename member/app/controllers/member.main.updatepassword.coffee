Spine   = require('spine')

Custom = require('models/custom')
Person = require('models/person')
$       = Spine.$

class myUpdatePassword extends Spine.Controller
	className: 'myupdatepassword'

	elements:
		"form":'formEl'
		'form ul li span:eq(2)':'passwordstrongEl'
		'form ul li img':'validateEl'
		'input[type=password]':'passwordEl'
		'input[name=selectall]':'selectallEl'
		'input[type=text]':'verifycodeEl'
  
	events:
		'keyup input[name=pwd1]':'checkPass'
		'blur input':'isValid'
		'click form input[type=submit]':'submit'
		'click form ul li img':'updateValidate'
  
	constructor: ->
		super

		@active @change

		Person.bind "beforeUpdate beforeDestroy", ->
			Person.url = "woo/index.php"+Person.url if Person.url.indexOf("woo/index.php") is -1
			Person.url += "&token="+sessionStorage.token unless Person.url.match /token/

	render: ->
		@html require("views/updatepassword")
	
	change: (params) =>

		token = sessionStorage.token
		$.getJSON "? cmd=VerifyStatus&token=#{token}",(result)=>
			@log result
			if result.status is false
				switch result.error
					when "Identity verify is invalid!"
						@navigate  "/members/password"
					else
						window.history.back(-1)
			else
				@render()

	testpass = (password, username)->
		score = 0
		return -4 if password.length < 4
		return -2 if typeof (username) isnt 'undefined' and password.toLowerCase() is username.toLowerCase()
		score += password.length * 4
		score += (repeat(1, password).length - password.length) * 1
		score += (repeat(2, password).length - password.length) * 1
		score += (repeat(3, password).length - password.length) * 1
		score += (repeat(4, password).length - password.length) * 1
		score += 5 if password.match(/(.*[0-9].*[0-9].*[0-9])/)
		score += 5 if password.match(/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/)
		score += 10 if password.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)
		score += 15 if password.match(/([a-zA-Z])/) && password.match(/([0-9])/)
		score += 15 if password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([0-9])/)
		score += 15 if password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([a-zA-Z])/)
		score -= 10 if password.match(/^\w+$/) || password.match(/^\d+$/)
		score = 0 if score < 0
		score = 100 if score > 100
		score
	repeat = (len, str)->
		res = ""
		for i in [0..str.length]
			repeated = on
			max = str.length - i - len
			min = Math.min max,len
			for j in [0..min]
				repeated = repeated && (str.charAt(j + i) == str.charAt(j + i + len))
			repeated = off if j < len
			if repeated
				i += len - 1
				repeated = off
			else 
				res += str.charAt(i)
		res
	checkPass:(e)->
		e.stopPropagation()
		pass = $(e.target).val()
		user = Person.first().username or 'username'
		score = testpass(pass, user)
		password_label = $(@passwordstrongEl)
		if (score == -4)
			password_label.html("<span style='height:20px;line-height:20px;display:inline-block;'>太短</span>");
		else if (score == -2)
			password_label.html("<span style='height:20px;line-height:20px;display:inline-block;'>与用户名相同</span>");
		else
			color = if score < 34 then '#edabab' else if score < 68 then '#ede3ab' else '#d3edab'
			text = if score < 34 then '弱' else if score < 68 then '一般' else '很好'
			width = score*2.2 + 'px'
			password_label.html("<span style='width:" + width + ";display:inline-block;overflow:hidden;height:20px;line-height:20px;background:" + color + ";'>" + text + "</span>");

	isValid:(e)->
		name = $(e.target).attr("name")
		value = $(e.target).val()
		basename = name.toLowerCase()
		errinfo = $("#" + basename + "_err_info")
		switch (basename)
			when "pwd1","pwd2"
				info = if /^[\w\-\!\@\#\$\%\^\&\*]{6,16}$/.test(value) then "通过"else "密码格式错误"
			when "validate"
				info = if /^[a-zA-Z0-9]{4}$/.test(value) then "通过"else "校验码格式错误"
			else
				return off
		errinfo.css("color",if info is "通过" then "green" else "red")
		errinfo.html(info)
		if info isnt "通过"
			$(e.target).focus()
			return false

	updateValidate:(e)->
		url = 'admin/checkNum_session.php?' + Math.ceil(Math.random() * 1000);
		$(@validateEl).attr "src",url

	submit:(e)->
		e.stopPropagation()
		e.preventDefault()
		key = $(@formEl).serializeArray()
		if key[0].value isnt key[1].value
			$(@passwordEl).val ""
			$(@passwordEl).eq(0).keyup()
			for i in [0..1]
				name = key[i].name
				basename = name.toLowerCase()
				errinfo = $("#" + basename + "_err_info")
				errinfo.css "color","red"
				errinfo.html "两次输入的密码不同！"
			$(@passwordEl).eq(0).focus()
			return off
		$.ajax
			url: "? cmd=UpdatePassword&token="+sessionStorage.token   # 提交的页面
			data: $(@formEl).serialize() # 从表单中获取数据
			type: "POST"                   # 设置请求类型为"POST"，默认为"GET"
			dataType : 'json'
			beforeSend: ->          # 设置表单提交前方法
				# new screenClass().lock();
			error: (request)->      # 设置表单提交出错
				console.log request
				alert("表单提交出错，请稍候再试")
			success: (data)=>
				if data.status
					alert "恭喜您，密码修改成功！" 
				else
					switch data.error
						when "Validate Code Error"
							$(@verifycodeEl).val ""
							$("#validate_err_info").html( "验证码错误").css "color","red"
							@updateValidate()
							$(@verifycodeEl).focus()
						else
							alert data.error


module.exports = myUpdatePassword