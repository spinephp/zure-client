Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

Word    = require('controllers/sysadmin.employee.option.departmentadd.text')
Verify   = require('controllers/main.verifycode')

class DepartmentEdits extends Spine.Controller
	tag:"form"
	className: 'departmentedits'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify
		@token = $.fn.cookie('PHPSESSID')
    
		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			item = {department:{}}
			@item = @word.getItem()
			$.fn.makeRequestParam @el,item,['D_'],[ @item.department]
			param = JSON.stringify(item)

			#@item.department.scope = 'woo'

			$.fn.ajaxPut @item.department.url(),param,(data)=>
				if data.id > -1
					alert "数据保存成功！"
					@item.department.updateAttributes data.department[0],ajax: false
					Department.trigger "update",@item.department[0]
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


module.exports = DepartmentEdits