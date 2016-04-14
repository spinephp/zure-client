User = require('models/user')
loginDialog = require('controllers/loginDialog')
myYunruiDialog = ->
	__refactor__ = true #是否需要重新构建 该对话框
	open: (options)->
		dlgAddOrder = $("#myYunruiDialog")
		dlgAddOrder.remove() if __refactor__

		html = ""
		kind = 0
		sum = 0
		html += "<div id='myYunruiDialog'>"
		if options.user?
			html += "<p>#{options.defaults.toPinyin(options.user.nick or options.user.name)}<span><a href='?cmd=Member'>#{options.defaults.translate 'Go my YunRui'}</a> | <a href='###' id='userlogout'>#{options.defaults.translate 'Logout'}</a></span></p>"
		else
			html += "<p>#{options.defaults.translate 'Hello, please'} [<a href='###' id='userlogin'>#{options.defaults.translate('Login')}</a>]</p>"
		html += "<p>#{options.defaults.translate('The latest order status')}: <a href='###'>#{options.defaults.translate('Check all order')}></a></p>"
		
		html += "<ul><li><a href='?cmd=Member#/members/order'>#{options.defaults.translate('Pending orders')}(#{options.orders.Pending()})</a></li>"
		html += "<li><a href='?cmd=Member#/members/consult'>#{options.defaults.translate('Consulting reply')}(#{options.consults.unreadReply()})</a></li>"
		html += "<li><a href='?cmd=Member#/members/carefly'>#{options.defaults.translate('Prices of goods')}(0)</a></li></ul>"
		
		html += "<ul><li><a href='?cmd=Member#/members/carefly'>#{options.defaults.translate('My attention')}></a></li></ul>"
		html += "</div>"

		$(html).appendTo("body")

		# 用户用户登录处理程序
		$("#userlogin").click ()->
			loginDialog().open(default:options.defaults,user:options.user)

		# 用户登出处理程序
		$("#userlogout").click (e)->
			e.stopPropagation()
			$.post "? cmd=Logout", $(@formEl).serialize(), (result)=>
				User.destroyAll()
				unless result.id is -1
					#@navigate '!/customs/login'
				else 
					alert(result.username) # 显示登录失败信息
				$("#myYunruiDialog").dialog('close')

		width = $("header ul li:first-child").width()
		offset = $("header ul li:first-child").position()
		scrollY = $("body").scrollTop()
		$("#myYunruiDialog").dialog
			autoOpen: false
			closeOnEscape: true
			width: '400px'
			position: [offset.left+width-400, offset.top+27-scrollY]    # 赋值弹出坐标位置
			modal: false
			#title: "添加订单"

		.hover (-> $(@).addClass("hover")),->
			$(@).removeClass("hover")
			$(@).dialog("close")
		.dialog('widget').find(".ui-dialog-titlebar").hide()
		$("#myYunruiDialog").dialog("open")
		__refactor__ = false

module.exports = myYunruiDialog
