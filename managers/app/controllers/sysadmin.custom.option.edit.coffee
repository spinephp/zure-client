Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')

$		= Spine.$

citySelector   = require('controllers/cityselector')

class CustomEdits extends Spine.Controller
	className: 'customedits'
  
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

		@custom = $.Deferred()
		@person = $.Deferred()

		Custom.bind "refresh",=>@custom.resolve()
		Person.bind "refresh",=>@person.resolve()
  
	render: ->
		@html require("views/fmcustoms")(@item)
		@person = Person.find @item.customs.userid
		county = ["","",""] 
		if @person.county isnt ""
			county = [@person.county[0..1],@person.county[0..3],@person.county]
		citySelector.Init($(@addressEl),county, on)
		$("body >header h2").text "经营管理->客户管理->编辑客户"
	
	change: (params) =>
		try
			$.when( @custom,@person).done =>
				if Custom.exists params.id
					custom = Custom.find params.id
					@item = 
						customs:custom
						persons:Person.find custom.userid
					@render()
		catch err
			@log "file: sysadmin.main.coffee\nclass: CustomEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	uploadHeadshot:(e)->
		e.stopPropagation()
		$.fn.uploadFile 'userimg'+@item.customs.userid,@fileheadEl[0].files[0],$(@headshotimgEl),'images/user/'

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
		item = {custom:{},person:{}}
		$.fn.makeRequestParam @formEl,item,['C_','P_'],[ @item.customs,@item.persons]
		item['custom']['userid'] = @item.persons.id

		headshot = $(@headshotimgEl).attr 'src'
		name = headshot.replace 'images/user/',''
		item.person['picture'] = name if name isnt @person.picture

		param = JSON.stringify(item)
		@item.customs.scope = 'woo'
		$.ajax
			url: @item.customs.url() # 提交的页面
			data: param
			type: "PUT" # 设置请求类型为"POST"，默认为"GET"
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
					@item.persons.updateAttributes data.person[0],ajax: false
					@item.customs.updateAttributes data.custom[0],ajax: false
					Custom.trigger 'update',@item.customs
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							$(".validate").click()
							$(@verifyEl).focus()


module.exports = CustomEdits