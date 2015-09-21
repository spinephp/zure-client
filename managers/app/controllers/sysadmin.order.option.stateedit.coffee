Spine	= require('spine')
Orderstate = require('models/orderstate')

$		= Spine.$

class OrderstateEdits extends Spine.Controller
	className: 'orderstateedits'
  
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
		$("body >header h2").text "经营管理->订单管理->编辑订单状态"
	
	change: (params) =>
		try
			if Orderstate.exists params.id
				@item = 
					orderstate:Orderstate.find params.id
					orderstatees:Orderstate.all()
				@render()
		catch err
			@log "file: sysadmin.main.order.option.stateedit.coffee\nclass: OrderstateEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)->
		e.preventDefault()
		item = {orderstate:{}}
		$.fn.makeRequestParam @formEl,item,['S_'],[@item.orderstate]

		param = JSON.stringify(item)

		@item.orderstate.scope = 'woo'

		$.ajaxPut @item.orderstate.url(),param,(data)=>
			if data.id > -1
				alert "数据保存成功！"
				@item.orderstate.updateAttributes data.orderstate,ajax: false
				Orderstate.trigger 'update',@item.orderstate
			else
				switch data.error
					when "Access Denied"
						window.location.reload()
					when "Validate Code Error!"
						alert "验证码错误，请重新填写。"
						$(".validate").click()
						$(@verifyEl).focus()


module.exports = OrderstateEdits