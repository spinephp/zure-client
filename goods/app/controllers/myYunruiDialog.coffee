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
			html += "<p>#{options.defaults.toPinyin(options.user.nick or options.user.name)}<span><a href='?cmd=Member'>#{options.defaults.translate 'Go my YunRui'}</a></span></p>"
		else
			html += "<p>#{options.defaults.translate 'Hello, please'} [<a href='###'>#{options.defaults.translate('Login')}</a>]</p>"
		html += "<p>#{options.defaults.translate('The latest order status')}: <a href='###'>#{options.defaults.translate('Check all order')}></a></p>"
		
		html += "<ul><li><a href='?word=myorder'>#{options.defaults.translate('Pending orders')}(#{options.orders.Pending()})</a></li>"
		html += "<li><a href='?word=myconsult'>#{options.defaults.translate('Consulting reply')}(#{options.consults.unreadReply()})</a></li>"
		html += "<li><a href='?word=mycarefly'>#{options.defaults.translate('Prices of goods')}(0)</a></li></ul>"
		
		html += "<ul><li><a href='?word=mycarefly'>#{options.defaults.translate('My attention')}></a></li></ul>"
		html += "</div>"

		$(html).appendTo("body")

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
