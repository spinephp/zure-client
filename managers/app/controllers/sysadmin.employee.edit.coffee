Spine	= require('spine')
Employee = require('models/employee')
Person = require('models/person')
Department = require('models/department')

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
  
	render: ->
		@html require("views/fmemployees")(@item)
		county = ["","",""] 
		if @item.persons.county isnt ""
			county = [@item.persons.county[0..1],@item.persons.county[0..3],@item.persons.county]
		citySelector.Init($(@addressEl),county, on)
		$("body >header h2").text "劳资管理->员工管理->编辑员工资料"
	
	change: (params) =>
		try
			employee = Employee.find params.id
			@item = 
				employees:employee
				persons:Person.find employee.userid
				departments:Department.all()
			@render()
		catch err
			@log "file: sysadmin.main.coffee\nclass: EmployeeEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	uploadFile:(key,file,img,path)->
		try
			throw 'File Size > 4M' if file.size > 4*1024*1024
			throw "Invalid File Type #{file.type}" unless file.type in ['image/jpg','image/jpeg','image/png','image/gif']
			formdata = new FormData()
			formdata.append(key, file)
			options = 
				type: 'POST'
				url: '? cmd=Upload&token='+@token
				data: formdata
				success:(result) =>
					img.attr 'src',path+result.image
					alert(result.msg)
				processData: false  # 告诉jQuery不要去处理发送的数据
				contentType: false   # 告诉jQuery不要去设置Content-Type请求头
				dataType:"json"
			$.ajax(options)
		catch error
			alert error

	uploadHeadshot:(e)->
		e.stopPropagation()
		@uploadFile 'userimg'+@item.employees.userid,@fileheadEl[0].files[0],$(@headshotimgEl),'images/user/'

	uploadWatermask:(e)->
		e.stopPropagation()
		@uploadFile 'maskimg',@filemaskEl[0].files[0],$(@waterimgEl),'images/'

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
		item = $.fn.makeRequestParam e,@formEl,['person','employee'],['P_','E_'],[@item.persons,@item.employees]
		headshot = $(@headshotimgEl).attr 'src'
		name = headshot.replace 'images/user/',''
		item.person['picture'] = name if name isnt @item.persons.picture

		param = JSON.stringify(item)
		@item.employees.scope = 'woo'
		$.ajaxPut @item.employees.url(),param,(data)=>
			if data.id > -1
				alert "数据保存成功！"
				@item.persons.updateAttributes data.person,ajax: false
				@item.employees.updateAttributes data.employee,ajax: false
				@navigate('/sysadmins/employee') 
			else
				switch data.error
					when "Access Denied"
						window.location.reload()
					when "Validate Code Error!"
						alert "验证码错误，请重新填写。"
						$(".validate").click()
						$(@verifyEl).focus()


module.exports = EmployeeEdits