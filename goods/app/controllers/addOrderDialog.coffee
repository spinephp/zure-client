addOrderDialog = ->
	__refactor__ = true #是否需要重新构建 该对话框
	open: (options)->
		dlgAddOrder = $("#addOrderDialog")
		dlgAddOrder.remove() if __refactor__

		str = "<div id='addOrderDialog'>
					<img src='images/Ok.png' />
					<h3>"+options.default.translate("The order added successfully")+"！</h3>
					<p>"+options.default.translate("Orders containing")+" "+options.kind+" "+options.default.translate("kinds of products")+"</p><p>"+options.default.translate("A combined")+"："+options.symbol+"<span>"+options.price+"</span></p>
				</div>"

		$(str).appendTo "body"
			

		$("#addOrderDialog").dialog
			autoOpen: false
			closeOnEscape: true
			width: '420px'
			modal: true
			title: options.default.translate("Add order")
			buttons: 
				"订单结算": ->
					__refactor__ = true
					location.href = "? cmd=ShowOrder&token="+sessionStorage.token
				"关闭": ->
					$("#addOrderDialog").dialog "close"
		$("#addOrderDialog").dialog "open"
		__refactor__ = false

module.exports = addOrderDialog
