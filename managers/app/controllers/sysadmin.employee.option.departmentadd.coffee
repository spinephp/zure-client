Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

Word    = require('controllers/sysadmin.employee.option.departmentadd.text')
Verify   = require('controllers/main.verifycode')

class DepartmentAdds extends Spine.Controller
	tag:"form"
	className: 'departmentadds'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@image    = new Image 'userimg','user',"50%"
		@verify    = new Verify
		@token = $.fn.cookie('PHPSESSID')

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.preventDefault()
			item = {department:{}}
			@item = @word.getItem()
			$.fn.makeRequestParam @el,item,['D_']
			item['action'] = 'department_create'
			
			param = JSON.stringify(item)
			Department.scope  = ''
			$.ajax
				url: Department.url # 提交的页面
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
						@item.department.updateAttributes data.department[0],ajax: false
						Department.trigger "create",@item.department[0]
						#@navigate('/department/',data.id,'show') 
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


module.exports = DepartmentAdds