Spine   = require('spine')

Ordercomplain = require('models/ordercomplain')
Complain = require('models/complain')
Orderproduct = require('models/orderproduct')
Order = require('models/order')
Goodclass = require('models/goodclass')
Default = require('models/default')
$       = Spine.$

class myComplains extends Spine.Controller
	className: 'mycares'

	elements:
		".tabs":'tabsEl'
		".tabs ul li:last-child": 'addcomplaintitle'
		'#editcomplain':'addcomplainbody'
		'td input:checked':'checkedEl'
		'input[name=selectall]': 'selectallEl'
  
	events:
		'click #selectorder td:last-child button': 'addComplain'
		'click #editcomplains input[type=submit]':'addAComplain'
		'click input[name=selectall]': 'selectall'
		'click td:last-child a:last-child': 'cancelACare'
		'click .care-item-head p> a': 'cancelCares'
  
	constructor: ->
		super
		@active @change

		@type = $.Deferred()
		@complain = $.Deferred()
		@order = $.Deferred()
		@orderproduct = $.Deferred()
		@goodclass = $.Deferred()
		@good = $.Deferred()
		@default = $.Deferred()

		Ordercomplain.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText+error

		Complain.bind "refresh",=>@type.resolve()
		Ordercomplain.bind "refresh",=>@complain.resolve()
		Orderproduct.bind "refresh",=>@orderproduct.resolve()
		Goodclass.bind "refresh",=> @goodclass.resolve()
		Default.bind "refresh",=> @default.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()

		Order.bind "refresh",@afterfetch

		Complain.fetch()
		Ordercomplain.fetch()
		Order.fetch()
		Goodclass.fetch() if Goodclass.count() is 0

		Ordercomplain.bind "beforeUpdate beforeDestroy", ->
			Ordercomplain.url = "woo/index.php"+Ordercomplain.url if Ordercomplain.url.indexOf("woo/index.php") is -1
			Ordercomplain.url += "&token="+sessionStorage.token unless Ordercomplain.url.match /token/

	render: ->
		@html require("views/complain")(@item)
		$(@tabsEl).tabs()
		
	change: (params) =>
		try

			$.when( @orderproduct,@complain,@type,@goodclass,@default).done( =>
				defaults = Default.first()
				@item = 
					complains:Ordercomplain.all()
					orders:Order.all()
					types:Complain.all()
					goods:Orderproduct
					klass:Goodclass
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.coffee\nclass: myComplains\nerror: #{err.message}"

	afterfetch:=>
		if Order.count() > 0
			values = []
			i = 0
			for rec in Order.all()
				values[i++] = pro.proid for pro in rec.products when pro.proid not in values
			Orderproduct.append values if i > 0
		else
			@orderproduct.resolve()

	selectall:(e)=>
		e.stopPropagation()
		state = $(e.target).is ':checked'
		$(@selectallEl).prop 'checked',state
		$(@selectEl).prop 'checked',state
		
	addComplain:(e)->
		e.preventDefault()
		e.stopPropagation()
		complainorderid = $(e.target).attr 'data-id'
		$(@tabsEl).find('ul li:last-child').removeClass "hide"
		$(@tabsEl).tabs
			active: 2
			select:(event, ui)->
				console.log '1111111111'
				$(@).find('ul li:last-child').addClass "hide"
		$("#complain-orderno").html complainorderid

	dlgAddOrder:->
		m = 0
		Cart.each (item)->
			m += item.number*Product.find(item.proid).price
		addOrderDialog().open({ kind: Cart.count(), price: m })

	# 提交一个抱怨
	addAComplain:(e)=>
		e.preventDefault()
		e.stopPropagation()
		parent = $(e.target).parent()
		orderid = parent.find('span').text()
		type = parent.find('select').val()
		content = parent.find('textarea').val()
		item = new Ordercomplain orderid:orderid,content:content,type:type,status:'S'
		oldUrl = Ordercomplain.url
		Ordercomplain.url += "&token="+sessionStorage.token unless Ordercomplain.url.match /token/
		item.bind 'save',(item)=>
			@render()
		item.save()
		Ordercomplain.url = oldUrl
		$(@tabsEl).tabs
			active: 0

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

module.exports = myComplains