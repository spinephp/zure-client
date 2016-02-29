Spine	= require('spine')
Goodclass = require('models/goodclass')

$		= Spine.$

Word    = require('controllers/sysadmin.good.option.classadd.text')
Image   = require('controllers/image_option')

class GoodclassAdds extends Spine.Controller
	tag:"form"
	className: 'goodclassadds'
   
	constructor: ->
		@active @change
		super
		@word = new Word
		@image    = new Image 'goodimg','good'
		@token = $.fn.cookie('PHPSESSID')
    
		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			item = {productclass:{}}
			$.fn.makeRequestParam @el,item,['G_']

			item.productclass['picture'] = $.fn.getImageName @image.getImage().attr 'src'
			item.action = "productclass_create"
			param = JSON.stringify(item)
			$.ajax
				url: "? cmd=ProductClass" # 提交的页面
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
						#@item.goodclass.updateAttributes data.productclass[0],ajax: false
						Goodclass.trigger "create",data.productclass
						#Spine.trigger "imagechange",@item.goodclass.picture
					else
						switch data.error
							when "Access Denied"
								window.location.reload()
							when "Validate Code Error!"
								alert "验证码错误，请重新填写。"
								Spine.trigger "updateverify"	   
		@append @word, @image,option
		$("body >header h2").text "经营管理->产品管理->添加产品类"
		
	change: (params) =>
		@word.active params
		@image.active params

module.exports = GoodclassAdds