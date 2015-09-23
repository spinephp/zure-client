Spine	= require('spine')
User = require('models/user')
Employee = require('models/employee')
Person = require('models/person')
Department = require('models/department')
Right = require('models/right')

$		= Spine.$

citySelector   = require('controllers/cityselector')

class EmployeeEdits extends Spine.Controller
	className: 'employeeedits'
  
	elements:
		"button":"buttonEl"
		'form':'formEl'
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
		'form >div:last-child >img':"headshotimgEl"
		'.watermode img':"waterimgEl"
		'input[name=upload_head]':'fileheadEl'
		'input[name=upload_mask]':'filemaskEl'
		'input[name=code]':'verifyEl'
		'.waterType':'watermaskEl'
		'.watermode':'watermodeEl'
  
	events:
		'click .validate':'verifyCode'
		'change input[name=upload_head]':'uploadHeadshot'
		'change input[name=upload_mask]':'uploadWatermask'
		'click input[name=upload_head]+p button':'headshotClick'
		'click .watermode p button':'waterimageClick'
		'click input[name=watermask]': 'watermaskClick'
		'click input[name=watersel]': 'waterselClick'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@token = $.fn.cookie('PHPSESSID')
		@active @change

		@department = $.Deferred()
		@employee = $.Deferred()
		@person = $.Deferred()

		Department.bind "refresh",=>@department.resolve()
		Employee.bind "refresh",=>@employee.resolve()
		Person.bind "refresh",=>@person.resolve()
		
		Spine.bind "userlogined",(item)->
			Right.fetch() if item.state & parseInt "0x00002000",16
  
	render: ->
		@html require("views/fmemployees")(@item)
		@person = Person.find @item.employees.userid
		county = ["","",""] 
		if @person.county isnt ""
			county = [@person.county[0..1],@person.county[0..3],@person.county]
		citySelector.Init($(@addressEl),county, on)
		$("body >header h2").text "劳资管理->员工管理->编辑员工资料"
	
	change: (params) =>
		try
			$.when( @department,@employee,@person).done =>
				if Employee.exists params.id
					employee = Employee.find params.id
					@item = 
						employees:employee
						persons:Person.find employee.userid
						departments:Department.all()
						users:User.first()
					@item.rights = Right.all() if Right.count() > 0
					@render()
		catch err
			@log "file: sysadmin.option.edit.coffee\nclass: EmployeeEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	uploadHeadshot:(e)->
		e.stopPropagation()
		$.fn.uploadFile 'userimg'+@item.employees.userid,@fileheadEl[0].files[0],$(@headshotimgEl),'images/user/'

	uploadWatermask:(e)->
		e.stopPropagation()
		$.fn.uploadFile 'maskimg',@filemaskEl[0].files[0],$(@waterimgEl),'images/'

	headshotClick:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@fileheadEl).click()

	waterimageClick:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@filemaskEl).click()
	
	watermaskClick:(e)->
		e.stopPropagation()
		display = if $(e.target).is(':checked') then 'block' else 'none'
		$(@watermaskEl).css 'display',display
		
	waterselClick:(e)->
		e.stopPropagation()
		$(@watermodeEl)
			.css('display','none')
			.eq($(e.target).val())
			.css 'display','block'

	option: (e)->
		e.preventDefault()
		opt = $(e.target)
		key = $(@formEl).serializeArray()
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
		headshot = $(@headshotimgEl).attr 'src'
		name = headshot.replace 'images/user/',''
		item.person['picture'] = name if name isnt @person.picture
		item.token = @token

		param = JSON.stringify(item)
		#@item.employees.scope = 'woo'
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
						$(".validate").click()
						$(@verifyEl).focus()


module.exports = EmployeeEdits