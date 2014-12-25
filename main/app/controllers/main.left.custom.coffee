Spine   = require('spine')
User = require('models/user')
Default = require('models/default')
$       = Spine.$
Manager = require('spine/lib/manager')

class Logins extends Spine.Controller
	className: 'logins'
	# 填充内部元素属性
	elements:
		"form":"formEl"
		"img":"vdImg"
	
	# 委托事件
	events:
		"click input[name=login]": "login"
		"click input[name=userRegister]": "userRegister"
		"click input[name=validate]": "resetValidate"

	constructor: ->
		super
		@active @change
		
		@default = $.Deferred()
		Default.bind "refresh",=>@default.resolve() if Default.count() > 0
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
		
	render: =>
		@html require('views/fmLogin')(@item)

	change: (item) =>
		try
			$.when(@default).done =>
				@item = 
					default:Default.first()
				@render()
		catch err
			console.log err.message

	# 用户登录
	login:()->
		key = $(@formEl).serializeArray()
		unless /^[a-zA-Z]{1}[a-zA-Z0-9\-\_\@\.]{4,16}[a-zA-Z0-9]{1}$/.test(key[0].value)
			alert("用户名格式不正确")
			return false
		
		unless /^[\w\-\!\@\#\$\%\^\&\*]{6,16}$/.test(key[1].value)
			alert("密码格式不正确")
			return false
		
		unless /^\d{4}$/.test(key[2].value)
			alert("校验码格式不正确")
			return false
		
		$(@tokenEl).val(@token)
		
		# AJAX 提交用户登录信息
		$.post "? cmd=CheckLogin", $(@formEl).serialize(), (result)=>
			if result[0] is "{"
				obj = JSON.parse(result)
				if typeof (obj) is "object"
					unless obj.id is -1
						item = new User(obj)# 新建本地用户信息
						item.save()
						@navigate '!/customs/logout'
					else 
						alert(obj.username)# 显示登录失败信息
						@resetValidate()
	
	# 用户注册
	userRegister:()-> registerDialog().open()
	
	# 重置校验码
	resetValidate: ()->
		url = 'admin/checkNum_session.php?' + Math.ceil(Math.random() * 1000)
		$(@vdImg).attr("src",url)
		
###
客户退出登录
###
class Logouts extends Spine.Controller
	className: 'logouts'
	# 填充内部元素属性
	elements:
		"form":"formEl"
		"img":"vdImg"
	
	# 委托事件
	events:
		"click input[name=logout]": "logout"
		"click p a": "myClick"

	constructor: ->
		super
		@active @change
		
		@user = $.Deferred()
		@default = $.Deferred()
		User.bind "refresh change",=>@user.resolve()
		Default.bind "refresh",=>@default.resolve() if Default.count() > 0
		
	render: =>
		@html require('views/fmLogout')(@item)

	change: (item) =>
		try
			$.when(@user,@default).done =>
				@item = 
					user:User.first()
					default:Default.first()
				@render()
		catch err
			console.log err.message
	
	# 用户登出
	logout:(e)->
		e.stopPropagation()
		$.post "? cmd=Logout", $(@formEl).serialize(), (result)->
			if result[0] is "{"
				obj = JSON.parse(result)
				if typeof (obj) is "object"
					unless obj.id is -1
						User.destroyAll()
						#@navigate '!/customs/login'
					else 
						alert(obj.username) # 显示登录失败信息
	
	myClick: (e)->
		e.stopPropagation()
		obj = $(e.target).attr("data-action")
		switch(obj)
			when "order"
				url = "? cmd=Member#/members/order"
			when "yunrui"
				url = "? cmd=Member#/members"
		window.location.assign(url)

class Customs extends Spine.Stack
	className: 'customs stack'
	
	controllers:
		login: Logins
		logout: Logouts

module.exports = Customs