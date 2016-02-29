Spine	= require('spine')
Goodclass = require('models/goodclass')

$		= Spine.$

Word    = require('controllers/sysadmin.good.option.classadd.text')
Image   = require('controllers/image_option')

class GoodclassEdits extends Spine.Controller
	tag:"form"
	className: 'goodclassedits'
  
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
			param = JSON.stringify(item)
			$.fn.ajaxPut @word.getGoodclass().url(),param,(data)=>
				if data.id > -1
					alert "数据保存成功！"
					#@item.goodclass.updateAttributes data.productclass,ajax: false
					Goodclass.trigger 'update',data.productclass[0]
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

module.exports = GoodclassEdits