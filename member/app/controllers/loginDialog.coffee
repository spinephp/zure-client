loginDialog = ->
	__refactor__ = true #是否需要重新构建 该对话框
	open: (options)->
		dlgAddOrder = $('#loginDialog')
		dlgAddOrder.remove() if __refactor__

		str = "<div id='loginDialog'>
					<form id='fmlogindialog' name='fmlogindialog'>
					<p><input type='text' name='username' placeholder='#{options.default.translate 'Enter username'}' /><span>* </span><span id='username_err_info'></span></p>
					<p><input type='password' name='pwd' placeholder='#{options.default.translate 'Enter password'}' /><span>* </span><span id='password_err_info'></span></p>
					<p><input type='text' name='code' placeholder='#{options.default.translate 'Enter char in box'}' /><span>* </span><span id='verify_err_info'></span> <img id='validate' src='admin/checkNum_session.php' align='absmiddle' style='border:#CCCCCC 1px solid; cursor:pointer;' title='#{options.default.translate 'Click get another pin'}' width=50 height=20 /></p>
					<p><input type='hidden' name='action' value='custom_login' /><input type='hidden' name='token' value='user_token' /> <a href='fogot_form.php'> #{options.default.translate 'Forget password'}?</a></p>
					</form>
				</div>"

		$(str).appendTo "body"
		
		# 重置校验码
		$("#validate").click ()->
			url = 'admin/checkNum_session.php?' + Math.ceil(Math.random() * 1000)
			console.log 'aaa'+$(this)
			$(this).attr("src",url)
			
		$("#loginDialog").dialog
			autoOpen: false
			closeOnEscape: true
			width: '500px'
			modal: true
			title: options.default.translate 'Custom login'
			buttons: 
				'Login': ->
					__refactor__ = true
					vuser = options.default.translate 'Invalid username'
					vpwd  = options.default.translate 'Invalid password'
					vpin = options.default.translate 'Invalid verify code'
					info = [
						{"name":"username","reg":/^[a-zA-Z]{1}[a-zA-Z0-9\-\_\@\.]{4,16}[a-zA-Z0-9]{1}$/,"msg":vuser}
						{"name":"password","reg":/^[\w\-\!\@\#\$\%\^\&\*]{6,16}$/,"msg":vpwd}
						{"name":"verify","reg":/^[0-9]{4}$/,"msg":vpin}
					]
					$('#fmlogindialog input[name=token]').val $.fn.cookie 'PHPSESSID'
					key = $('#fmlogindialog').serializeArray()
					name = $('#fmlogindialog input')
					for i in [0..2]
						err = $("#"+info[i].name+"_err_info")
						err.html ""
						unless info[i].reg.test(key[i].value)
							err.html(info[i].msg).css "color","red"
							name.eq(i).foucs()
							return false
					console.log key
					$.getJSON '? cmd=CheckLogin',$.param(key),(result)->
						console.log result
						if result.id is -1
							switch result.username
								when "Invalid user name!"
									$('#username_err_info').html vuser
									name.eq(0).foucs().select()
								when 'Password error!'
									$('#password_err_info').html vpwd
									name.eq(1).foucs().select()
								when 'Validate Code Error'
									$('#verify_err_info').html vpin
									name.eq(2).foucs().select()
								else
									alert result.username
									$('#loginDialog').dialog 'close'
						else
							item = options.user.first() or new options.user
							item.updateAttribute result
							$('#loginDialog').dialog 'close'
							options.sucess?()
						return on
				'Close': ->
					$('#loginDialog').dialog 'close'
			open:->
				# 翻译按钮文本
				btns =  $(@).next().find('button span')
				$(btn).text options.default.translate $(btn).text() for btn in btns

		$('#loginDialog').dialog 'open'
		__refactor__ = false

module.exports = loginDialog
