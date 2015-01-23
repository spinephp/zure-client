Spine   = require('spine')
Catalog = require('models/catalog')
Qiye = require('models/qiye')
Employee = require('models/employee')
Person = require('models/person')
User = require('models/user')
Order = require('models/order')
Orderstate = require('models/orderstate')
Department = require('models/department')
$       = Spine.$
Exports = require('controllers/sysadmin.export')
Goods = require('controllers/sysadmin.good')
Orders = require('controllers/sysadmin.order')
Progress = require('controllers/sysadmin.progress')
Employees = require('controllers/sysadmin.employee')
Customs = require('controllers/sysadmin.custom')

class Logins extends Spine.Controller
	className: 'logins'
  
	elements:
		"input":"input"
		"form": "form"
		"img":"img"

	events:
		'click button': 'login'
		"click img": "resetValidate"
  
	constructor: ->
		super
		@active @change
  
	render: ->
		@html require('views/login')()
		$("body >header h2").text "用户登录"
	
	change: (params) =>
		try
			@render()
		catch err
			@log "file: sysadmin.main.coffee, error:#{err.message}"
	
	# 用户登录
	login:=>
		username = $(@input[0]).val()
		userpwd = $(@input[1]).val()
		validate = $(@input[2]).val()
		if not /^\w{6,18}$/.test(username)
			alert("用户名格式不正确")
			return false
		
		if not /^[\w\-\!\@\#\$\%\^\&\*]{6,16}$/.test(userpwd)
			alert("密码格式不正确")
			return false
		
		if not /^\d{4}$/.test(validate)
			alert("校验码格式不正确")
			return false
		
		$(@input[3]).val($.fn.cookie("PHPSESSID"))
			
		# AJAX 提交用户登录信息
		$.post("? cmd=CheckLogin", $(@form).serialize(), (result)=>
			if result[0] is "{"
				obj = JSON.parse(result)
				if typeof(obj) is "object"

					# 设置 token
					if obj.token?
						sessionStorage.token = obj.token 
						delete obj.token

					if obj.id isnt -1
						item = User.first()
						if typeof(item) isnt "undefined"
							item.updateAttributes(obj) # 更新本地用户信息
						else
							item = new User(obj) # 新建本地用户信息
							item.save()
						nav = ""

						# 根据管理者权限，设置相应功能模块
						@setRight parseInt(item.state)

						Spine.trigger "userlogined",item

						Qiye.fetch()
						Order.fetch()
						Orderstate.fetch()

						nav = "/sysadmins"
						
						@navigate(nav) if nav?
					else
						alert(result)  # 显示登录失败信息
						@resetValidate()
			else
				alert(result)  # 显示登录失败信息
				@resetValidate()
		)

	# 设置用户权限
	setRight:(state) ->
		catalog = Catalog.all()

		catalog[0].state |= 32 if state & 0x80000000		# 查看站点信息
		catalog[0].state |= 16 if state & parseInt("0x40000000")		# 编辑站点信息
		catalog[0].state |= 8 if state & parseInt("0x20000000")			# 查看新闻信息
		catalog[0].state |= 4 if state & parseInt("0x10000000")			# 编辑新闻信息
		catalog[0].state |= 2 if state & parseInt("0x08000000")			# 查看留言
		catalog[0].state |= 1 if state & parseInt("0x04000000")			# 编辑留言

		catalog[1].state |= 128 if state & parseInt("0x02000000")		# 显示客户信息
		catalog[1].state |= 64 if state & parseInt("0x01000000")		# 编辑客户信息
		catalog[1].state |= 32 if state & parseInt("0x00800000")		# 查看产品类
		catalog[1].state |= 16 if state & parseInt("0x00400000")		# 编辑产品类
		catalog[1].state |= 8 if state & parseInt("0x00200000")			# 查看产品
		catalog[1].state |= 4 if state & parseInt("0x00100000")			# 编辑产品
		catalog[1].state |= 2 if state & parseInt("0x00080000")			# 查看订单
		catalog[1].state |= 1 if state & parseInt("0x00040000")			# 编辑订单

		catalog[2].state |= 2 if state & parseInt("0x00020000")			# 查看生产进度
		catalog[2].state |= 1 if state & parseInt("0x00010000")			# 编辑生产进度

		catalog[3].state |= 4 if state & parseInt("0x00008000")			# 查看雇员信息
		catalog[3].state |= 2 if state & parseInt("0x00004000")			# 编辑雇员信息
		catalog[3].state |= 1 if state & parseInt("0x00002000")			# 设置管理者权限

		
	# 重置校验码
	resetValidate:->
		url = 'admin/checkNum_session.php?' + Math.ceil(Math.random() * 1000)
		$(@img).attr("src",url)

	edit: ->
		@navigate('/sysadmins', @item.id, 'edit')

class Qiyes extends Spine.Controller
	className: 'qiyes'
  
	events:
		'click .edit': 'edit'
		'change input[type=text]':'recordchanged'
		'change select':'recordchanged'
		'click form input[type=submit]':'submit'
  
	constructor: ->
		super
		@active @change

		@qiye = $.Deferred()
		@person = $.Deferred()
		@employee = $.Deferred()
		Qiye.bind "refresh change",=>@qiye.resolve()

		Qiye.bind "beforeUpdate beforeDestroy", ->
			Qiye.url = "woo/index.php"+Qiye.url if Qiye.url.indexOf("woo/index.php") is -1
			Qiye.url += "&token="+sessionStorage.token unless Qiye.url.match /token/

		Person.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText
		Spine.bind "userlogined",(user)=>
			@employeefetch()
  
	render: ->
		state = Catalog.all()[0].state >> 4
		return if state & 3 is 0
		temp = if state & 1 is 1 then "fm" else ""
		@html require("views/#{temp}qiye")(@item)
		$("body >header h2").text "站点管理->站点信息"
	
	change: (params) =>
		try
			$.when( @qiye,@person,@employee).done( =>
				@item = {qiyes:Qiye.first(),employees:Employee.select (item)->item.departmentid in [5,6]}
				@render()
			)
		catch err
			@log "file: sysadmin.main.coffee\nclass: Qiyes\nerror: #{err.message}"

	employeefetch:->
		Employee.bind "refresh",=>
			@personfetch()
			@employee.resolve()
		Employee.fetch() if Employee.count() is 0

	personfetch:->
		Person.one "refresh",=>@person.resolve()
		ids = (item.userid for item in Employee.all() when not Person.exists item.userid)
		Person.append ids if ids.length > 0
	
	edit: ->
		@navigate('/sysadmins', @item.id, 'edit')

	recordchanged:(e)->
		e.preventDefault()
		key = $(e.target).attr 'name'
		value = $(e.target).val()
		@item.qiyes[key] = value

	submit:(e)->
		e.preventDefault()

		oldUrl = Qiye.url
		Qiye.url += "&token="+$.fn.cookie("PHPSESSID") unless Qiye.url.match /token/
		@item.qiyes.save()
		Qiye.url = oldUrl

	
class Main extends Spine.Stack
	className: 'main stack'
	
	controllers:
		qiye: Qiyes
		employee: Employees
		custom: Customs
		good:Goods
		order: Orders
		progress:Progress
		login:Logins
		export:Exports
	
module.exports = Main