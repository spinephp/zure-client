Spine	= require('spine')
Orderstate = require('models/orderstate')

$		= Spine.$

Word    = require('controllers/sysadmin.order.option.stateadd.text')
Verify   = require('controllers/main.verifycode')

class OrderstateEdits extends Spine.Controller
	tag:"form"
	className: 'orderstateedits'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify
		@token = $.fn.cookie('PHPSESSID')

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			item = {orderstate:{}}
			@item = @word.getItem()
			$.fn.makeRequestParam @el,item,['S_'],[@item.orderstate]

			param = JSON.stringify(item)

			@item.orderstate.scope = ''

			$.fn.ajaxPut @item.orderstate.url(),param,(data)=>
				if data.id > -1
					alert "数据保存成功！"
					@item.orderstate.updateAttributes data.orderstate,ajax: false
					#Orderstate.trigger 'update',@item.orderstate
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

module.exports = OrderstateEdits