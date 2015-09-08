Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')
Country = require('models/country')

$		= Spine.$

citySelector   = require('controllers/cityselector')

class CustomAdds extends Spine.Controller
	className: 'customedits'
  
	elements:
		"button":"buttonEl"
		'form':'formEl'
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first p:eq(5) select':"countryEl"
		'form div:first p:eq(6) select':"addressEl"
		'form >div:eq(-1) >img':"customimgEl"
		'.watermode img':"waterimgEl"
		'input[name=upload_custom]':'filecustomEl'
		'input[name=upload_mask]':'filemaskEl'
		'input[name=code]':'verifyEl'
		'.waterType':'watermaskEl'
		'.watermode':'watermodeEl'
		'div:first-child p:nth-child(3) span':'intensityEl'
  
	events:
		'blur input':'verifyValue'
		'click .validate':'verifyCode'
		'change input[name=upload_custom]':'uploadCustom'
		'change input[name=upload_mask]':'uploadWatermask'
		'click input[name=upload_custom]+p button':'pickcustomimg'
		'click .watermode p button':'pickmaskimg'
		'click input[name=watermask]': 'watermaskClick'
		'click input[name=watersel]': 'waterselClick'
		'click input[type=submit]': 'option'
		'keyup input[type=password]':'showIntensity'
		'change form div:first p:eq(5) select':"countryChange"
  
	constructor: ->
		super
		@token = $.fn.cookie('PHPSESSID')
		@active @change

		@country = $.Deferred()
		
		Country.bind "refresh",=>@country.resolve()
  
	render: ->
		@html require("views/fmaddcustoms")(@item)
		$("body >header h2").text "经营管理->客户管理->添加客户"
		citySelector.Init($(@addressEl),["","",""], on)
	
	change: (params) =>
		try
			$.when( @country).done =>
				@item = 
					customs:new Custom
					persons:new Person
					countrys: Country.all()
			@render()
		catch err
			@log "file: sysadmin.main.custom.option.add.coffee\nclass: CustomAdds\nerror: #{err.message}"

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

	verifyValue:(e)->
		name = $(e.target).attr("name")
		value = $(e.target).val()
		basename = name.toLowerCase()
		errinfo = $("#" + basename + "_err_info")
		info = "通过"
		color = "green"
		switch  basename[2..]
			when "username"
				@checkUserName(value)
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

	countryChange:(e)->
		e.stopPropagation()
		obj = $(e.target)
		item = Country.find obj.val()
		obj.next().attr "src","images/country/#{item.code3}.png"	

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	# 处理产品图片改变事件，上传选择的产品图片
	uploadCustom:(e)->
		e.stopPropagation()
		$.fn.uploadFile 'userimg0',@filecustomEl[0].files[0],$(@customimgEl),'images/user/'

	# 处理水印图片改变事件，上传选择的水印图片
	uploadWatermask:(e)->
		e.stopPropagation()
		$.fn.uploadFile 'maskimg',@filemaskEl[0].files[0],$(@waterimgEl),'images/'

	# 处理"要上传的产品图像"按键点击事件
	pickcustomimg:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@filecustomEl).click()

	# 处理"要上传的水印图像"按键点击事件
	pickmaskimg:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@filemaskEl).click()
	
	# 处理"添加水印"检查框点击事件，根据检查框选中状态显示或隐藏水印功能界面
	watermaskClick:(e)->
		e.stopPropagation()
		display = if $(e.target).is(':checked') then 'block' else 'none'
		$(@watermaskEl).css 'display',display
		
	# 处理水印类型单选框点击事件，根据选中的单选框显示文本或图形水印功能界面
	waterselClick:(e)->
		e.stopPropagation()
		$(@watermodeEl)
			.css('display','none')
			.eq($(e.target).val())
			.css 'display','block'

	option: (e)->
		e.preventDefault()
		item = $.fn.makeRequestParam @formEl,['custom','person'],['C_','P_']

		img = $(@customimgEl).attr 'src'
		name = img.replace 'images/user/',''
		item.person['picture'] = name #if name isnt @item.department.picture

		param = JSON.stringify(item)
		$.ajax
			url: Custom.url # 提交的页面
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
					alert data.register+'\n'+data.email
					person = {}
					custom = {}
					person[item]=data.person[item] for item in Person.attributes
					custom[item]=data.custom[item] for item in Custom.attributes
					Person.refresh person,clear:false
					Custom.refresh custom,clear:false
					#@item.persons.updateAttributes person,ajax: false
					#@item.customs.updateAttributes custom,ajax: false
					@navigate('/customs/',data.id,'show') 
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							$(".validate").click()
							$(@verifyEl).focus()


module.exports = CustomAdds