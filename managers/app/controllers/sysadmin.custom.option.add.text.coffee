Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')
Country = require('models/country')

$		= Spine.$

citySelector   = require('controllers/cityselector')

class CustomAddTexts extends Spine.Controller
	className: 'textoption'
  
	elements:
		'tr td input[type=checkbox]':'selectedEl'
		'>p label+select:eq(0)':"countryEl"
		'select':"addressEl"
		'>p label+span:eq(0)':'intensityEl'
 
	events:
		'blur input':'verifyValue'
		'keyup input[type=password]':'showIntensity'
		'change >p label+select:eq(0)':"countryChange"
 
	constructor: ->
		super
		@active @change
		@country = $.Deferred()
		@custom = $.Deferred()
		@person = $.Deferred()

		Custom.bind "refresh",=>@custom.resolve()
		Person.bind "refresh",=>@person.resolve()
		Country.bind "refresh",=>@country.resolve()
		@token = $.fn.cookie('PHPSESSID')
  		#Persen.bind "create",(item)=>
			#@item.persons.updateAttributes item,ajax: false

	render: ->
		@html require("views/fmcustoms")(@item)
		county = ["","",""] 
		code = @item.persons.county
		if code?
			county = [code[0..1],code[0..3],code]
		citySelector.Init($(@addressEl[1..3]),county, on)
	
	change: (params) =>
		try
			$.when( @custom,@person,@country).done =>
				if Custom.exists params.id
					custom = Custom.find params.id
					person = Person.find custom.userid
				else
					custom = new Custom
					person = new Person
				@item = 
					customs:custom
					persons:person
					countrys:Country.all()
				@render()
				Spine.trigger "image:change",@item.persons.picture
		catch err
			@log "file: sysadmin.main.custom.option.add.text.coffee\nclass: CustomAddTexts\nerror: #{err.message}"

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

	getItem:->
		@item
		
module.exports = CustomAddTexts