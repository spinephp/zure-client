Spine   = require('spine')

myOrders    = require('controllers/member.main.order')
myCares    = require('controllers/member.main.care')
myComplains    = require('controllers/member.main.complain')
myAccounts    = require('controllers/member.main.account')
myBalances    = require('controllers/member.main.balance')
mySpendings    = require('controllers/member.main.spending')
myAppraises    = require('controllers/member.main.appraise')
myConsults    = require('controllers/member.main.consult')
myMessagees    = require('controllers/member.main.message')
myPasswords    = require('controllers/member.main.password')
myUpdatePasswords    = require('controllers/member.main.updatepassword')

Person = require('models/person')
Custom = require('models/custom')
Customgrade = require('models/customgrade')
Grade = require('models/grade')
Order = require('models/order')
Good = require('models/good')
Goodeval = require('models/goodeval')
Goodcare = require('models/goodcare')
Sysnotice = require('models/sysnotice')
Goodconsult = require('models/goodconsult')
Customaccount = require('models/customaccount')
Currency = require('models/currency')
Default = require('models/default')
$       = Spine.$

class myYunrui extends Spine.Controller
	className: 'myyunrui'

	elements:
		".tabs":'tabsEl'
		"#home-menu-2 button": 'btnCare'
  
	events:
		'click .home-intro p a': 'orderClick'
  
	constructor: ->
		super
		@active @change

		@person = $.Deferred()
		@custom = $.Deferred()
		@customgrade = $.Deferred()
		@grade = $.Deferred()
		@order = $.Deferred()
		@goodconsult = $.Deferred()
		@good = $.Deferred()
		@goodeval = $.Deferred()
		@sysnotice = $.Deferred()
		@customaccount = $.Deferred()
		@default = $.Deferred()
		@currency = $.Deferred()

		Customaccount.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText

		Goodcare.bind "refresh",@afterfetch

		Custom.bind "refresh",=> @custom.resolve()
		Customgrade.bind "refresh",=> @customgrade.resolve()
		Grade.bind "refresh",=> @grade.resolve()
		Order.bind "refresh",=> @order.resolve()
		Person.bind "refresh",=> @person.resolve()
		Good.bind "refresh",=> @good.resolve()
		Goodeval.bind "refresh",=> @goodeval.resolve()
		Goodconsult.bind "refresh",=> @goodconsult.resolve()
		Sysnotice.bind "refresh",=> @sysnotice.resolve()
		Customaccount.bind "refresh",=> @customaccount.resolve()
		Default.bind "refresh",=> @default.resolve()
		Currency.bind "refresh",=> @currency.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@item.currency = Currency.find @item.default.currencyid
				@render()

		Goodcare.fetch()
		Custom.fetch()
		Customgrade.fetch()
		Grade.fetch()
		Order.fetch()
		Person.fetch()
		Goodconsult.fetch()
		Sysnotice.fetch()
		Customaccount.fetch()

	render: ->
		@html require("views/yunrui")(@item)
		$(@tabsEl).tabs()
		$(".imagesets .imgscroll").jCarouselLite
			btnNext: ".imagesets .next"
			btnPrev: ".imagesets .prev"
		$(@btnCare).attr('disabled',"true") if Goodcare.count() < 4
	
	change: (params) =>
		try
			$.when( @person, @custom,@customgrade,@order,@grade,@good,@goodeval,@goodconsult,@customaccount,@sysnotice).done( =>
				custom = Custom.first()
				defaults = Default.first()
				@item = 
					custom:custom
					person:Person.first()
					customgrade:Customgrade.first()
					orders:Order
					products:Good.all()
					productconsults:Goodconsult.all()
					sysnotices:Sysnotice.all()
					customaccount:Customaccount.all()
					currency:Currency.find defaults.currencyid
					eval:Goodeval
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.coffee\nclass: myYunrui\nerror: #{err.message}"
	afterfetch:=>
		if Goodcare.count()>0
			fields = Good.attributes
			values = (rec.proid for rec in Goodcare.all())
			condition = [{field:"id",value:values,operator:"in"}]
			params = 
				data:{ cond:condition,filter: fields, token: sessionStorage.token } 
				processData: true
			Good.fetch(params)
			params1 = 
				data:{ cond:condition,filter:Goodeval.attributes, token: sessionStorage.token } 
				processData: true
			Goodeval.fetch params1
		else
			@good.resolve()
			@goodeval.resolve()
	
	orderClick: (e)->
		@navigate '/members/order'

class Main extends Spine.Stack
	className: 'main stack'
	
	controllers:
		yunrui: myYunrui
		order:myOrders
		care:myCares
		complain:myComplains
		account:myAccounts
		balance:myBalances
		spending:mySpendings
		appraise:myAppraises
		consult:myConsults
		message:myMessagees
		password:myPasswords
		updatepassword:myUpdatePasswords
	
module.exports = Main