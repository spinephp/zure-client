Spine	= require('spine')
Orderstate = require('models/orderstate')

$		= Spine.$

class OrderstateAdds extends Spine.Controller
	className: 'orderstateadds'
  
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
		Orderstate.bind "refresh",=>@change
  
	render: ->
		@html require("views/fmorderstate")(@item)
		$("body >header h2").text "经营管理->产品管理->添加产品类"
	
	change: (params) =>
		try
			@item = 
				orderstate:new Orderstate
				orderstatees:Orderstate.all()
			@render()
		catch err
			@log "file: sysadmin.main.good.option.classedit.coffee\nclass: OrderstateEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	


	option: (e)->
		e.preventDefault()
		item = {orderstate:{}}
		$.fn.makeRequestParam @formEl,item,['S_']

		param = JSON.stringify(item)
		$.ajax
			url: "? cmd=OrderState" # 提交的页面
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
					@item.orderstate.updateAttributes data,ajax: false
					Orderstate.trigger "create",@item.orderstate
					@navigate('/orders/state/',@item.orderstate.id,'show') 
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							$(".validate").click()
							$(@verifyEl).focus()


module.exports = OrderstateAdds