Spine	= require('spine')
Employee = require('models/employee')

$		= Spine.$

Word    = require('controllers/sysadmin.employee.option.add.text')
Image   = require('controllers/image_option')

class EmployeeAdds extends Spine.Controller
	tag:"form"
	className: 'employeeadds'
   
	constructor: ->
		@active @change
		super
		@word = new Word
		@image    = new Image 'userimg','user',"50%"
		@token = $.fn.cookie('PHPSESSID')

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e?.preventDefault()
			@item = @word.getItem()
			item = {employee:{},person:{}}
			$.fn.makeRequestParam @el,item,['E_','P_']

			item.person['picture'] = $.fn.getImageName @image.getImage().attr 'src'
			item.action = "employee_create"
			item.language = 1
			param = JSON.stringify(item)
			
			Employee.scope  = ''
			$.ajax
				url: Employee.url # 提交的页面
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
						@item.persons.updateAttributes data.person,ajax: false
						@item.employees.updateAttributes data.employee,ajax: false
						@navigate('/employees/',data.id,'show') 
					else
						switch data.error
							when "Access Denied"
								window.location.reload()
							when "Validate Code Error!"
								alert "验证码错误，请重新填写。"
								Spine.trigger "updateverify"	   
		@append @word, @image,option
		
	change: (params) =>
		@word.active params
		@image.active params

module.exports = EmployeeAdds