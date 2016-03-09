Spine	= require('spine')
Orderstate = require('models/orderstate')

$		= Spine.$

Word    = require('controllers/sysadmin.order.option.stateadd.text')
Verify   = require('controllers/main.verifycode')

class OrderstateAdds extends Spine.Controller
	tag:"form"
	className: 'orderstateadds'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify
		@token = $.fn.cookie('PHPSESSID')

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			item = {orderstate:{}}
			$.fn.makeRequestParam @el,item,['S_']

			param = JSON.stringify(item)
			Orderstate.scope = ''
			$.ajax
				url: Orderstate.url # 提交的页面
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
						@word.getItem().orderstate.updateAttributes data.orderstate,ajax: false
						#Orderstate.trigger "create",@item.orderstate
						@navigate('/orders/state/',@item.orderstate.id,'show') 
					else
						switch data.error
							when "Access Denied"
								window.location.reload()
							when "Validate Code Error!"
								alert "验证码错误，请重新填写。"
								Spine.trigger "updateverify"	 
								
		@append @word, @verify,option
		
	change: (params) =>
		@word.active params
		@verify.active params


module.exports = OrderstateAdds