Spine   = require('spine')

Cart = require('models/cart')
Goodcare = require('models/goodcare')
Goodclass = require('models/goodclass')
Goodeval = require('models/goodeval')
Good = require('models/good')
Currency = require('models/currency')
Default = require('models/default')
$       = Spine.$
addOrderDialog = require('controllers/addOrderDialog')

class myCares extends Spine.Controller
	className: 'mycares'

	elements:
		".tabs":'tabsEl'
		"#care-item-2 button": 'btnCare'
		'.imgscroll ul li':'scrollImgEl'
		'.paging':'barPageEl'
		".paging button": 'btnPageEl'
		'td input:checkbox':'selectEl'
		'td input:checked':'checkedEl'
		'.care-item-show input:checked':'filtercheckedEl'
		'input[name=selectall]': 'selectallEl'
  
	events:
		'click td button': 'addtoorder'
		'click .care-item-head p> button':'addtoorders'
		'click input[name=selectall]': 'selectall'
		'click td:last-child a:last-child': 'cancelACare'
		'click .care-item-head p> a': 'cancelCares'
		'click .care-item-show input:radio': 'selectCares'
		'click .care-item-show input:checkbox': 'howShowCares'
		'click .paging button':'pagingClick'
  
	constructor: ->
		super
		@active @change
		@currPage=0

		@care = $.Deferred()
		@eval = $.Deferred()
		@goodclass = $.Deferred()
		@good = $.Deferred()
		@default = $.Deferred()
		@currency = $.Deferred()

		Goodcare.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText+error

		Goodcare.bind "refresh",@afterfetch

		Good.bind "refresh",=> @good.resolve()
		Goodeval.bind "refresh",=> @eval.resolve()
		Goodclass.bind "refresh",=> @goodclass.resolve()
		Default.bind "refresh",=> @default.resolve()
		Currency.bind "refresh",=> @currency.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()

		Goodcare.fetch()
		Goodclass.fetch()

		Goodcare.bind "beforeDestroy", ->
			Goodcare.url = "woo/index.php"+Goodcare.url if Goodcare.url.indexOf("woo/index.php") is -1
			Goodcare.url += "&token="+$.fn.cookie('PHPSESSID') unless Goodcare.url.match /token/

		$(window).resize =>
			$(".imagesets .imgscroll").jCarouselLite
				visible:($('#care-item-2').width()-2*$(@btnCare).width())/($(@scrollImgEl).width()+45)

	render: ->
		@html require("views/carefuly")(@item)
		$(@tabsEl).tabs()
		$(".imagesets .imgscroll").jCarouselLite
			btnNext: ".imagesets .next"
			btnPrev: ".imagesets .prev"
			visible:($('#care-item-2').width()-2*$(@btnCare).width())/($(@scrollImgEl).width()+45)
			auto:1000
			speed:800
		$(@btnCare).attr('disabled',"true") if Goodcare.count() < 5
		$(@btnPageEl).button()
		@_setPageButtons()
	
	change: (params) =>
		try

			$.when( @care,@good,@goodclass,@default,@currency).done( =>
				defaults = Default.first()
				@basecares = Goodcare.all()
				@item = 
					goods:Good
					productcares:@basecares
					evals:Goodeval
					klass:Goodclass
					currency:Currency
					defaults:defaults
					filterclass:0
					filterlabel:0
					careshowchecked:[off,off,off]
					pages:
						records:5
						current:@currPage
				@render()
			)
		catch err
			@log "file: member.main.coffee\nclass: myCares\nerror: #{err.message}"
	afterfetch:=>
		@care.resolve()
		if Goodcare.count() > 0
			values = []
			i = 0
			values[i++] = rec.proid for rec in Goodcare.all()  when not Good?.exists(rec.proid) and rec.proid not in values
			Good.append values if i > 0
		else
			@good.resolve()

	selectall:(e)=>
		e.stopPropagation()
		state = $(e.target).is ':checked'
		$(@selectallEl).prop 'checked',state
		$(@selectEl).prop 'checked',state
		
	addOrder:(target)->
		gid = target.closest('tr').attr 'data-id'
		gitem = Goodcare.find gid
		proid = gitem.proid
		aorder = Cart.findByAttribute("proid", proid) or new Cart({ proid: proid, number: 0, time: new Date() })
		aorder.number++
		aorder.save()

	dlgAddOrder:->
		m = 0
		Cart.each (item)->
			m += item.number*Good.find(item.proid).price
		addOrderDialog().open
			kind: Cart.count()
			price: m
			default:@item.defaults
			symbol:Currency.find(@item.defaults.currencyid).symbol

	addtoorder:(e)=>
		e.preventDefault()
		e.stopPropagation()
		@addOrder $(e.target)
		@dlgAddOrder()

	addtoorders:(e)=>
		e.preventDefault()
		e.stopPropagation()
		if $('td input:checked').length>0
			$(@selectEl).each (i,item)=>
				@addOrder $(item) if $(item).is ':checked'
			@dlgAddOrder()

	cancelCare:(target,fun)->
		gid = target.closest('tr').attr 'data-id'
		item = Goodcare.find  gid
		item.bind 'destroy',fun if fun?
		oldUrl = Goodcare.url
		item.destroy()
		Goodcare.url = oldUrl

	cancelACare:(e)=>
		e.preventDefault()
		e.stopPropagation()
		@cancelCare $(e.target),(delrecord)=>
			@item.productcares = Goodcare.all()
			@render()

	cancelCares:(e)=>
		e.preventDefault()
		e.stopPropagation()
		if $('td input:checked').length>0
			@cancelCare $(item) for item in $(@selectEl) when $(item).is ':checked'
			@navigate('/members/carefly')

	selectCares:(e)->
		e?.stopPropagation()
		@basecares = Goodcare.all()
		value = $(e.target).val()
		name = $(e.target).attr 'name'
		if @basecares.length > 0
			switch name
				when 'filterclass'
					@basecares=(care for care in @basecares when @_isParents care.proid,parseInt value) if value isnt '0'
					@item.filterclass = parseInt value
					@item.filterlabel = 0
				when 'filterlabel'
					@item.filterclass = 0
					@item.filterlabel = parseInt value
		@item.productcares = @_makeCares()
		@render()
	
	# 产生要求的产品关注数组				
	_makeCares:->
		@currPage = 0
		cares = @basecares
		for i in [0..2]
			if @item.careshowchecked[i]
				switch i
					when 0
						cares=(care for care in cares when @_isDownPrice care) if cares.length > 0
					when 1
						cares=(care for care in cares when Good.find(care.proid).amount > 0) if cares.length > 0
					when 2
						cares=(care for care in cares when Good.find(care.proid).status is 'P') if cares.length > 0
		cares

	# 判断 gid 指定的商品是否是 pid 指定的商品分类的
	_isParents:(gid,pid)->
		good = Good.find gid
		klass = Goodclass.find good.classid
		while klass.parentid isnt pid
			if Goodclass.exists klass.parentid
				klass = Goodclass.find klass.parentid
			else
				klass = null
				break
		if klass is null then false else true

	_isDownPrice:(caregood)->
		tem = Good.find caregood.proid
		currency = Currency.find Default.first().currencyid
		caregood.price/caregood.exchangerate > tem.price/currency.exchangerate

	howShowCares:(e)->
		e?.stopPropagation()
		value = parseInt $(e.target).val()
		@item.careshowchecked[value] = $(e.target).is ':checked'
		@item.productcares = @_makeCares()
		@render()

	edit: ->
		@navigate('/members', @item.id, 'edit')

	_setPageButtons:->
		for page,kind in $(@barPageEl)
			btns = $(page).find 'button'
			$(btns).button 'disabled':false
			lastPage = Math.ceil @item.productcares.length/@item.pages.records
			if @currPage is 0
				$(btns[0]).button 'disabled':true
			if @currPage+1 is lastPage
				$(btns[1]).button 'disabled':true

	# 分页控制
	pagingClick:(e)->
		e?.stopPropagation()
		lastPage = Math.ceil @item.productcares.length/@item.pages.records
		btn = $(e.target)
		if $(btn).next('button').length > 0
			@CurrPage-- if @CurrPage > 0
		else if $(btn).prev('button').length >0
			@CurrPage++ if @CurrPage < lastPage
		@render()

module.exports = myCares