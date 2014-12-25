Spine   = require('spine')
User = require('models/user')
Default = require('models/default')
$       = Spine.$
Manager = require('spine/lib/manager')

class Logins extends Spine.Controller
	className: 'logins'
	# ����ڲ�Ԫ������
	elements:
		"form":"formEl"
		"img":"vdImg"
	
	# ί���¼�
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

	# �û���¼
	login:()->
		key = $(@formEl).serializeArray()
		unless /^[a-zA-Z]{1}[a-zA-Z0-9\-\_\@\.]{4,16}[a-zA-Z0-9]{1}$/.test(key[0].value)
			alert("�û�����ʽ����ȷ")
			return false
		
		unless /^[\w\-\!\@\#\$\%\^\&\*]{6,16}$/.test(key[1].value)
			alert("�����ʽ����ȷ")
			return false
		
		unless /^\d{4}$/.test(key[2].value)
			alert("У�����ʽ����ȷ")
			return false
		
		$(@tokenEl).val(@token)
		
		# AJAX �ύ�û���¼��Ϣ
		$.post "? cmd=CheckLogin", $(@formEl).serialize(), (result)=>
			if result[0] is "{"
				obj = JSON.parse(result)
				if typeof (obj) is "object"
					unless obj.id is -1
						item = new User(obj)# �½������û���Ϣ
						item.save()
						@navigate '!/customs/logout'
					else 
						alert(obj.username)# ��ʾ��¼ʧ����Ϣ
						@resetValidate()
	
	# �û�ע��
	userRegister:()-> registerDialog().open()
	
	# ����У����
	resetValidate: ()->
		url = 'admin/checkNum_session.php?' + Math.ceil(Math.random() * 1000)
		$(@vdImg).attr("src",url)
		
###
�ͻ��˳���¼
###
class Logouts extends Spine.Controller
	className: 'logouts'
	# ����ڲ�Ԫ������
	elements:
		"form":"formEl"
		"img":"vdImg"
	
	# ί���¼�
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
	
	# �û��ǳ�
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
						alert(obj.username) # ��ʾ��¼ʧ����Ϣ
	
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