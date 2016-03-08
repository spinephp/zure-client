Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')

$		= Spine.$

Word    = require('controllers/sysadmin.custom.option.add.text')
Image   = require('controllers/image_option')
Verify   = require('controllers/main.verifycode')

class CustomAdds  extends Spine.Controller
	tag:"form"
	className: 'customadds'
   
	constructor: ->
		@active @change
		super
		@word = new Word
		@image    = new Image 'userimg','user',"50%"
		@verify    = new Verify
		@token = $.fn.cookie('PHPSESSID')

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			item = {custom:{},person:{}}
			$.fn.makeRequestParam @el,item,['C_','P_']

			item.person['picture'] = $.fn.getImageName @image.getImage().attr 'src'
			item.action = "custom_create"
			item.language = 1
			param = JSON.stringify(item)
			Custom.scope  = ''
			$.ajax
				url: Custom.url # 提交的页面
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
						alert data.register+'\n'+data.email
						person = {}
						custom = {}
						person[item]=data.person[item] for item in Person.attributes
						custom[item]=data.custom[item] for item in Custom.attributes
						Person.refresh person,clear:false
						Custom.refresh custom,clear:false
						#@item.persons.updateAttributes person,ajax: false
						#@item.customs.updateAttributes custom,ajax: false
						@navigate('/customs/',data.id,'show') 
					else
						switch data.error
							when "Access Denied"
								window.location.reload()
							when "Validate Code Error!"
								alert "验证码错误，请重新填写。"
								Spine.trigger "updateverify"	   
		@append @word, @image,@verify,option
		
	change: (params) =>
		@word.active params
		@image.active params
		@verify.active params

module.exports = CustomAdds