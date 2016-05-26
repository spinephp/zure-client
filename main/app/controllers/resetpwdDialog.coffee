resetpwdDialog = ->
	__refactor__ = true #是否需要重新构建 该对话框
	open: (options)->
		dlgResetPWD = $('#resetpwdDialog')
		dlgResetPWD.remove() if __refactor__

		token = $.fn.cookie 'PHPSESSID'
		str = "<div id='resetpwdDialog'>
					<form id='fmresetpwdDialog' name='fmresetpwdDialog'>
					<p><input type='text' name='username' placeholder='#{options.default.translate 'Enter username'}' /><span>* </span><span id='username_err_info'></span></p>
					<p><input type='email' name='email' placeholder='#{options.default.translate 'Enter email'}' /><span>* </span><span id='email_err_info'></span></p>
					<p><input type='text' name='code' placeholder='#{options.default.translate 'Enter char in box'}' /><span>* </span><span id='verify_err_info'></span> <img id='validate' src='admin/checkNum_session.php' align='absmiddle' style='border:#CCCCCC 1px solid; cursor:pointer;' title='#{options.default.translate 'Click get another pin'}' width=50 height=20 /></p>
					<p><input type='hidden' name='language' value='#{options.default.languageid-1}' /><input type='hidden' name='type' value='ResetPassword' /><input type='hidden' name='action' value='custom_resetPassword' /><input type='hidden' name='token' value='#{token}' /> </p>
					</form>
				</div>"

		$(str).appendTo "body"
		
		# 重置校验码
		$("#validate").click ()->
			url = 'admin/checkNum_session.php?' + Math.ceil(Math.random() * 1000)
			$(this).attr("src",url)
			
		$("#resetpwdDialog").dialog
			autoOpen: false
			closeOnEscape: true
			width: '500px'
			modal: true
			title: options.default.translate 'Reset password'
			buttons: 
				'Submit': ->
					__refactor__ = true
					vuser = options.default.translate 'Invalid username'
					vemail  = options.default.translate 'Invalid email'
					vpin = options.default.translate 'Invalid verify code'
					info = [
						{"name":"username","reg":/^[a-zA-Z]{1}[a-zA-Z0-9\-\_\@\.]{4,16}[a-zA-Z0-9]{1}$/,"msg":vuser}
						{"name":"email","reg":/^(\w)+(\.\w+)*@(\w)+((\.\w+)+)$/,"msg":vemail}
						{"name":"verify","reg":/^[0-9]{4}$/,"msg":vpin}
					]
					$('#fmresetpwddialog input[name=token]').val token
					key = $('#fmresetpwdDialog').serializeArray()
					name = $('#fmresetpwdDialog input')
					for i in [0..2]
						err = $("#"+info[i].name+"_err_info")
						err.html ""
						unless info[i].reg.test(key[i].value)
							err.html(info[i].msg).css "color","red"
							name.eq(i).foucs()
							return false
					$.getJSON '? cmd=ResetPassword',$.param(key),(result)=>
						if result.id is -1
							switch result.username
								when "Invalid user name!"
									$('#username_err_info').html vuser
									name.eq(0).foucs().select()
								when 'Invalid email'
									$('#email_err_info').html vpwd
									name.eq(1).foucs().select()
								when 'Validate Code Error'
									$('#verify_err_info').html vpin
									name.eq(2).foucs().select()
								else
									alert result.username
									$('#resetpwdDialog').dialog 'close'
						else
							$('#resetpwdDialog').dialog 'close'
							options.sucess?()
						return on
				'Close': ->
					$('#resetpwdDialog').dialog 'close'
			open:->
				# 翻译按钮文本
				btns =  $(@).next().find('button span')
				$(btn).text options.default.translate $(btn).text() for btn in btns

		$('#resetpwdDialog').dialog 'open'
		__refactor__ = false

module.exports = resetpwdDialog
