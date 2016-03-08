Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')

$		= Spine.$

Word    = require('controllers/sysadmin.custom.option.add.text')
Image   = require('controllers/image_option')
Verify   = require('controllers/main.verifycode')

citySelector   = require('controllers/cityselector')

class CustomEdits extends Spine.Controller
	tag:"form"
	className: 'customedits'
   
	constructor: ->
		@active @change
		super
		@word = new Word
		@image    = new Image 'userimg','user',"50%"
		@verify    = new Verify
		@token = $.fn.cookie('PHPSESSID')

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			@item = @word.getItem()
			item = {custom:{},person:{}}
			$.fn.makeRequestParam @el,item,['C_','P_'],[ @item.customs,@item.persons]
			item['custom']['userid'] = @item.persons.id

			item.person['picture'] = $.fn.getImageName @image.getImage().attr 'src'

			param = JSON.stringify(item)
			Custom.scope = 'woo'
			$.fn.ajaxPut @item.customs.url(),param,(data)=>
				if data.id > -1
					alert "数据保存成功！"
					@item.persons.updateAttributes data.person[0],ajax: false
					@item.customs.updateAttributes data.custom[0],ajax: false
					Custom.trigger 'update',@item.customs
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

module.exports = CustomEdits