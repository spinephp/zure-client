Spine	= require('spine')
Employee = require('models/employee')
$		= Spine.$

Word    = require('controllers/sysadmin.employee.option.add.text')
Image   = require('controllers/image_option')
Verify   = require('controllers/main.verifycode')
Right   = require('controllers/sysadmin.employee.right')

class EmployeeEdits extends Spine.Controller
	tag:"form"
	className: 'employeeedits'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@image    = new Image 'userimg','user',"50%"
		@verify    = new Verify
		@right    = new Right 
		@token = $.fn.cookie('PHPSESSID')

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			@item = @word.getItem()
			opt = $(e.target)
			key = $(@el).serializeArray()
			_myright = 0
			item = {person:{},employee:{}}
			for field in key
				ckey = field.name[2..]
				cval = $.trim(field.value)
				if cval isnt ''
					switch field.name[0..1]
						when 'P_'
							item.person[ckey] = cval if cval isnt @item.persons[ckey]
						when 'E_'
							item.employee[ckey] = cval if cval isnt @item.employees[ckey] or ckey is 'userid'
						when 'R_'
							_myright |= cval
						else
							item[field.name] = cval
			item.employee.myright = _myright if _myright isnt 0
			item.person['picture'] = $.fn.getImageName @image.getImage().attr 'src'
			item.language = 1
			item.token = @token

			param = JSON.stringify(item)
			Employee.scope = 'woo'
			$.fn.ajaxPut @item.employees.url(),param,(data)=>
				if data.id > -1
					alert "数据保存成功！"
					@item.persons.updateAttributes data.person[0],ajax: false if data.person?
					@item.employees.updateAttributes data.employee[0],ajax: false
					Employee.trigger 'update',@item.employees
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							Spine.trigger "updateverify"	   
		@append @word, @image,@right,@verify,option
		
	change: (params) =>
		@word.active params
		@image.active params
		@right.active params
		@verify.active params


module.exports = EmployeeEdits