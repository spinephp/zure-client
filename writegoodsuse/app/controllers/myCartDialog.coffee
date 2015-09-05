myCartDialog = ->
	__refactor__ = true #是否需要重新构建 该对话框
	open: (options)->
		dlgAddOrder = $("#myCartDialog")
		dlgAddOrder.remove() if __refactor__

		html = ""
		kind = 0
		sum = 0
		html += "<div id='myCartDialog'>"
		html += "<h4>#{options.defaults.translate('The newest goods')}</h4>"
		html += "<table>"
		for cart in options.carts
			rec = cart.aRecordEx()
			klass = options.goodclass.find rec.classid
			price = (rec.price-rec.returnnow)/options.currency.exchangerate
			html += "<tr><td><a href='? cmd=ShowProducts&gid=#{cart.proid}'><img src='images/good/#{rec.image}' width=48 height=32 />"
			html += "#{options.defaults.translates(klass.longNames())}<br />#{rec.size}</a></td>"
			html += "<td><span>#{options.currency.symbol + price.toFixed(2)}</span>*#{cart.number}<br /><a href='#' product-data='#{cart.proid}'>#{options.defaults.translate('Delete')}</a></td></tr>"
			kind += 1
			sum += price * cart.number
		html += "</table>"
		html += "<p>#{options.defaults.translate('A total of')} #{kind} #{options.defaults.translate('records')}, #{options.defaults.translate('A combined')}：<span>#{options.currency.symbol + sum.toFixed(2)}</span></p>"
		html += "<p><button>#{options.defaults.translate('Order settlement')}</button></p>"
		html += "</div>"

		$(html).appendTo("body")

		$("#myCartDialog button").button().click ->
			location.href = "? cmd=ShowOrder&token="+$.fn.cookie 'PHPSESSID'

		$("#myCartDialog").delegate "a", "click", ->
			proid = $(this).attr("product-data")
			item = Cart.findByAttribute("proid", proid)
			item.destroy()

		width = $("header ul li:last-child").width()
		offset = $("header ul li:last-child").position()
		scrollY = $("body").scrollTop()
		$("#myCartDialog").dialog
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
		# $("#myCartDialog").dialog('widget').find(".ui-dialog-buttonpane").hide()
		$("#myCartDialog").dialog("open")
		__refactor__ = false

module.exports = myCartDialog
