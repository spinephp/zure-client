addOrderDialog = ->
	__refactor__ = true #是否需要重新构建 该对话框
	open: (options)->
		dlgAddOrder = $("#addOrderDialog")
		dlgAddOrder.remove() if __refactor__

		str = "<div id='addOrderDialog'>
					<img src='images/Ok.png' width=48 height=48 />
					<h3>订单添加成功！</h3>
					<p>订单包含 "+options.kind+" 种产品，合计："+options.symbol+"<span>"+options.price+"</span></p>
				</div>"

		$(str).appendTo "body"
			

		$("#addOrderDialog").dialog
			autoOpen: false
			closeOnEscape: true
			width: '400px'
			modal: true
			title: "添加订单"
			buttons: 
				"订单结算": ->
					__refactor__ = true
					location.href = "? cmd=ShowOrder&token="+sessionStorage.token
				"关闭": ->
					$("#addOrderDialog").dialog "close"
		$("#addOrderDialog").dialog "open"
		__refactor__ = false

module.exports = addOrderDialog
