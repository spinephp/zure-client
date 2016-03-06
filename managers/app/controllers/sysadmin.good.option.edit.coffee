Spine	= require('spine')
Goodclass = require('models/goodclass')
Goodsharp = require('models/goodsharp')
Good = require('models/good')

$		= Spine.$

Word    = require('controllers/sysadmin.good.option.add.text')
Image   = require('controllers/image_option')

class GoodEdits extends Spine.Controller
	tag:"form"
	className: 'goodedits'
   
	constructor: ->
		@active @change
		super
		@word = new Word
		@image    = new Image 'goodimg','good'
		@token = $.fn.cookie('PHPSESSID')
    
		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			@item = @word.getItem()
			item = {product:{}}
			$.fn.makeRequestParam @el,item,['G_'],[@item.good]

			item.product['picture'] = $.fn.getImageName @image.getImage().attr 'src'
			param = JSON.stringify(item)
			$.fn.ajaxPut @item.good.url(),param,(data)=>
				if data.id > -1
					alert "数据保存成功！"
					#@item.goodclass.updateAttributes data.productclass,ajax: false
					Good.trigger 'update',data.product[0]
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
		
module.exports = GoodEdits