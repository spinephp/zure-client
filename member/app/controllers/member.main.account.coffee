Spine   = require('spine')

Grade = require('models/grade')
Customgrade = require('models/customgrade')
Custom = require('models/custom')
Person = require('models/person')
Company = require('models/company')
Order = require('models/order')
Province = require('models/province')
Default = require('models/default')
Country = require('models/country')
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
		'select':"addressEl"
  
	events:
		'click input[type=button]': 'userSubmit'
		'change input[type=file]':'uploadHeadshot'
		'click form button':'headshotClick'
		'click #headshot >button':'headshotSave'
		'change li label+select:eq(0)':"countryChange"
  
	constructor: ->
		super
		@active @change

		@token = $.fn.cookie('PHPSESSID')
		
		@country = $.Deferred()
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

		Country.bind "refresh",=>@country.resolve()
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

		Country.fetch()

		Person.bind "beforeUpdate beforeCreate", =>
			Person.url = "woo/index.php"+Person.url if Person.url.indexOf("woo/index.php") is -1
			Person.url += "&token="+@token unless Person.url.match /token/

		Company.bind "beforeUpdate beforeCreate", =>
			Company.url = "woo/"+Company.url if Company.url.indexOf("woo/") is -1
			Company.url += "&token="+@token unless Company.url.match /token/
		
	render: ->
		@html require("views/account")(@item)
		$(@tabsEl).tabs()
		result = Person.first().county
		if result?
			area = [result[0..1],result[0..3],result]
		else
			area = ['','','']
		citySelector.Init($(@addressEl[1..3]),area, on)
		
	change: (params) =>
		try

			$.when( @grade,@custom,@customgrade,@order,@company,@country,@default).done( =>
				defaults = Default.first()
				@item = 
					grades:Grade
					orders:Order
					customs:Custom.first()
					company:Company.first()
					customgrades:Customgrade.first()
					countrys:Country.all()
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.coffee\nclass: myComplains\nerror: #{err.message}"

	customfetch:=>
		unless @person?
			@person = Person.first() 
			#@person.url("&token=#{@token}")
			id = parseInt @person?.companyid
			if id>=0
				Company.append [id] if not Company.exists id
			else
				Company.trigger "refresh"
			
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
		@person[cur.name] = cur.value for cur in key when cur.value isnt null
		addr = $(@addressEl)
		@person["country"] =  addr[0].value
		@person["county"] =  addr[3].value
		@person.bind 'save', (rec) =>
			@log rec
		
		@person.save()

	# 上载头像
	uploadHeadshot:(e)->
		try
			formdata = new FormData()
			formdata.append('userimg'+Person.first().id, @fileEl[0].files[0])
			options = 
				type: 'POST'
				url: '? cmd=Upload&token='+@token
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
		name = headshot.replace 'images/user/',''
		if name isnt 'noimg.png'
			@person.picture = name
		
			@person.save()


	# 提交更多用户信息
	addMore:=>
		key = $(@fmMoreInfoEl).serializeArray()
		co = (Company.first() or new Company)
		co[cur.name] = cur.value for cur in key when cur.name isnt "submitmore" and cur.value isnt null

		co.bind 'save', (rec) =>
			if rec.id >=0 and  @person.companyid is ""
				@person.companyid = rec.id 
				@person.save()
		#co.url("&token="+@token)
		co.save()


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

	countryChange:(e)->
		e.stopPropagation()
		obj = $(e.target)
		item = Country.find obj.val()
		obj.next().attr "src","images/country/#{item.code3}.png"	

	edit: ->
		@navigate('/members', @item.id, 'edit')

module.exports = myAccounts
