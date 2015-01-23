Spine   = require('spine')

Grade = require('models/grade')
Customgrade = require('models/customgrade')
Custom = require('models/custom')
Person = require('models/person')
Company = require('models/company')
Order = require('models/order')
Province = require('models/province')
Default = require('models/default')
$       = Spine.$
citySelector   = require('controllers/cityselector')

class myAccounts extends Spine.Controller
	className: 'myaccounts'

	elements:
		".tabs":'tabsEl'
		'form[name=basicinfo]': 'fmBasicInfoEl'
		'form[name=headshot]': 'fmHeadshotEl'
		'form[name=headshot] input[type=file]': 'fileEl'
		'form[name=moreinfo]': 'fmMoreInfoEl'
		'#editcomplain':'addcomplainbody'
		'.myheadshot img':'myheadshotImgEl'
		'td input:checked':'checkedEl'
		'input[type=file]':'headshotEl'
		'input[name=selectall]': 'selectallEl'
		'form:first-child select':"addressEl"
  
	events:
		'click input[type=button]': 'userSubmit'
		'change input[type=file]':'uploadHeadshot'
		'click form button':'headshotClick'
		'click #headshot >button':'headshotSave'
  
	constructor: ->
		super
		@active @change

		@grade = $.Deferred()
		@company = $.Deferred()
		@custom = $.Deferred()
		@customgrade = $.Deferred()
		@order = $.Deferred()
		@default = $.Deferred()

		Custom.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText+error
		Person.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText+error
		Order.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText+error

		Grade.bind "refresh",=>@grade.resolve()
		Company.bind "refresh",=>@company.resolve()
		Person.bind "refresh",@customfetch
		Custom.bind "refresh",=>@custom.resolve()
		Customgrade.bind "refresh",=>@customgrade.resolve()
		Order.bind "refresh",=> @order.resolve()
		Default.bind "refresh",=> @default.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()

		Province.fetch()
		Person.fetch()
		Grade.fetch()
		Customgrade.fetch()
		Order.fetch()
		Custom.fetch()

		Person.bind "beforeUpdate beforeDestroy", ->
			Person.url = "woo/index.php"+Person.url if Person.url.indexOf("woo/index.php") is -1
			Person.url += "&token="+sessionStorage.token unless Person.url.match /token/

	render: ->
		@html require("views/account")(@item)
		$(@tabsEl).tabs()
		result = Person.first().county
		if result?
			area = [result[0..1],result[0..3],result]
		else
			area = ['','','']
		citySelector.Init($(@addressEl),area, on)
		
	change: (params) =>
		try

			$.when( @grade,@custom,@customgrade,@order,@company,@default).done( =>
				defaults = Default.first()
				@item = 
					grades:Grade
					orders:Order
					customs:Custom.first()
					company:Company.first()
					customgrades:Customgrade.first()
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.coffee\nclass: myComplains\nerror: #{err.message}"

	customfetch:=>
		person = Person.first()
		if person?
			Company.append [person.companyid] if not Company?.exists person.companyid

	userSubmit:(e)=>
		e.preventDefault()
		e.stopPropagation()
		name = $(e.target).attr 'name'
		switch name
			when 'submitbasic'
				@addBasic()
			when 'submitmore'
				@addMore()
		
	# 提交基本用户信息
	addBasic:->
		key = $(@fmBasicInfoEl).serializeArray()
		item = Person.first()
		item[cur.name] = cur.value for cur in key when cur.value isnt null
		addr = $(@addressEl)
		item["county"] =  addr[2].value

		item.bind 'save', (rec) ->
			@log rec
		
		oldUrl = Person.url
		item.save()
		Person.url = oldUrl

	uploadHeadshot:(e)->
		try
			formdata = new FormData()
			formdata.append('userimg'+Person.first().id, @fileEl[0].files[0])
			options = 
				type: 'POST'
				url: '? cmd=Upload&token='+sessionStorage.token
				data: formdata
				success:(result) =>
					$('.myheadshot img').attr 'src','images/user/'+result.image
					alert(result.msg)
				processData: false  # 告诉jQuery不要去处理发送的数据
				contentType: false   # 告诉jQuery不要去设置Content-Type请求头
				dataType:"json"
			$.ajax(options)
		catch error
			alert error

	headshotClick:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@headshotEl).click()

	headshotSave:->
		headshot = $('.myheadshot img').attr 'src'
		name = headshot.replace 'images/user/',''
		if name isnt 'noimg.png'
			item = Person.first()
			item.picture = name
		
			Person.bind "beforeUpdate", ->
				Person.url = "woo/index.php"+Person.url if Person.url.indexOf("woo/index.php") is -1
				Person.url += "&token="+sessionStorage.token unless Person.url.match /token/
		
			oldUrl = Person.url
			item.save()
			Person.url = oldUrl


	# 提交更多用户信息
	addMore:=>
		key = $(@fmMoreInfoEl).serializeArray()
		item = Company.first()
		item[cur.name] = cur.value for cur in key when cur.value isnt null

		item.bind 'save', (rec) ->
			console.log rec
		
		Company.bind "beforeUpdate", ->
			Company.url = "woo/index.php"+Company.url if Company.url.indexOf("woo/index.php") is -1
			Company.url += "&token="+sessionStorage.token unless Company.url.match /token/
		
		oldUrl = Company.url
		item.save()
		Company.url = oldUrl

	addtoorders:(e)=>
		e.preventDefault()
		e.stopPropagation()
		if $('td input:checked').length>0
			$(@selectEl).each (i,item)=>
				@addOrder $(item) if $(item).is ':checked'
			@dlgAddOrder()

	cancelCare:(target)->
		proid = target.parent().parent().attr 'data-id'
		item = Ordercomplain.findByAttribute("proid", proid)
		oldUrl = Ordercomplain.url
		item.destroy()
		Ordercomplain.url = oldUrl

	cancelACare:(e)=>
		e.preventDefault()
		e.stopPropagation()
		@cancelCare $(e.target)
		@navigate('/members/carefly')

	cancelCares:(e)=>
		e.preventDefault()
		e.stopPropagation()
		if $('td input:checked').length>0
			$(@selectEl).each (i,item)=>
				@cancelCare $(item) if $(item).is ':checked'
			@navigate('/members/carefly')

	edit: ->
		@navigate('/members', @item.id, 'edit')

module.exports = myAccounts