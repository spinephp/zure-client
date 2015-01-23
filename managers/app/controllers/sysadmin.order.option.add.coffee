Spine	= require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')

$		= Spine.$

class OrderEdits extends Spine.Controller
	className: 'orderedits'
  
	elements:
		"button":"buttonEl"
		'form':'formEl'
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
		'input[name=code]':'verifyEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@token = $.fn.cookie('PHPSESSID')
		@active @change
		#Orderstate.bind "refresh",=>@change
  
	render: ->
		@html require("views/fmorder")(@item)
		$("body >header h2").text "经营管理->产品管理->编辑产品"
	
	change: (params) =>
		try
			@item = 
				order:new Order
				orderstates:Orderstate.all()
			@render()
		catch err
			@log "file: sysadmin.main.order.option.edit.coffee\nclass: OrderEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)->
		e.preventDefault()
		opt = $(e.target)
		key = $(@formEl).serializeArray()
		item = {product:{}}
		for field in key
			switch field.name[0..1]
				when 'G_'
					item.product[field.name[2..]] = field.value
				else
					item[field.name] = field.value

		param = JSON.stringify(item)
		$.ajax
			url: "? cmd=Order&token=#{@token}" # 提交的页面
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
					alert "数据保存成功！"
					@item.order.updateAttributes data,ajax: false
					Order.trigger "create",@item.order
					@navigate('/orders/',data.id,'show') 
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							$(".validate").click()
							$(@verifyEl).focus()


module.exports = OrderEdits