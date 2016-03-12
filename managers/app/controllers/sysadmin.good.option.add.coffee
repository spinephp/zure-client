Spine	= require('spine')
Goodclass = require('models/goodclass')
Good = require('models/good')

$		= Spine.$

Word    = require('controllers/sysadmin.good.option.add.text')
Image   = require('controllers/image_option')
Verify   = require('controllers/main.verifycode')

class GoodAdds extends Spine.Controller
	tag:"form"
	className: 'goodadds'
   
	constructor: ->
		@active @change
		super
		@word = new Word
		@image    = new Image 'goodimg','good'
		@verify    = new Verify
		@token = $.fn.cookie('PHPSESSID')
    
		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			#@item = @word.getItem()
			item = {product:{}}
			$.fn.makeRequestParam @el,item,['G_']

			item.product['picture'] = $.fn.getImageName @image.getImage().attr 'src'
			item.action = "product_create"
			param = JSON.stringify(item)
			$.ajax
				url: "? cmd=Product" # 提交的页面
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
						@word.getItem().good.updateAttributes data.product[0],ajax: false
						#Good.trigger "create",@item.good
						#Spine.trigger "imagechange",@item.goodclass.picture
					else
						switch data.error
							when "Access Denied"
								window.location.reload()
							when "Validate Code Error!"
								alert "验证码错误，请重新填写。"
								Spine.trigger "updateverify"	   
		@append @word, @image,@verify,option
		$("body >header h2").text "经营管理->产品管理->编辑产品"
		
	change: (params) =>
		@word.active params
		@image.active params
		@verify.active params

module.exports = GoodAdds