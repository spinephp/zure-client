Spine   = require('spine')

Order = require('models/order')
Orderproduct = require('models/orderproduct')
Payment = require('models/payment')
Consignee = require('models/consignee')
Orderstate = require('models/orderstate')
Goodclass = require('models/goodclass')
Default = require('models/default')
Currency = require('models/currency')
$       = Spine.$

class myOrders extends Spine.Controller
	className: 'myorders'

	elements:
		".ordertabs":'tabsEl'
		"#home-menu-2 button": 'btnCare'
  
	events:
		'click .edit': 'edit'
		'change select[name=orderstate]':'stateChange'
		'change select[name=ordertime]':'timeChange'
  
	constructor: ->
		super
		@active @change
		
		@product = $.Deferred()
		@goodclass = $.Deferred()
		@consignee = $.Deferred()
		@orderstate = $.Deferred()
		@payment = $.Deferred()

		Consignee.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText

		Order.bind "refresh",@afterfetch

		Consignee.bind "refresh",=> @consignee.resolve()
		Goodclass.bind "refresh",=> @goodclass.resolve()
		Payment.bind "refresh",=> @payment.resolve()
		Orderstate.bind "refresh",=> @orderstate.resolve()
		Orderproduct.bind "refresh",=> @product.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()

		#Order.fetch()

	render: ->
		@html require("views/orders")(@item)
		$(@tabsEl).tabs()
	
	change: (params) =>
		try

			$.when(@product,@consignee,@payment,@orderstate,@goodclass).done( =>
				defaults = Default.first()
				@item = 
					orders:Order
					ordermap:Order.all()
					options:[0,0]
					ordergood:Orderproduct
					klass:Goodclass
					currency:Currency.find defaults.currencyid
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.order.coffee\nclass: myOrders\nerror: #{err.message}"
	afterfetch:=>
		if Order.count() > 0
			values = []
			i = 0
			cvalues = []
			j = 0
			for rec in Order.all()
				for pro in rec.products when pro.proid not in values
					values[i++] = pro.proid 
				cvalues[j++] = rec.consigneeid unless rec.consigneeid in cvalues
			Orderproduct.append values if i > 0

			fields = Consignee.attributes
			condition = [{field:"id",value:cvalues,operator:"in"}]
			params = 
				data:{ cond:condition,filter: fields,token: $.fn.cookie 'PHPSESSID' } 
				processData: true
			Consignee.fetch(params)

			Payment.fetch()
			Orderstate.fetch()
		else
			@payment.resolve()
			@orderstate.resolve()
			@product.resolve()
			@consignee.resolve()
	
	edit: ->
		@navigate('/members', @item.id, 'edit')
		
	strtotime:(str)->
		_arr = str.split(' ')
		_day = _arr[0].split('-')
		_arr[1] or= '0:0:0'
		_time = _arr[1].split(':')
		for i in [_day.length - 1..0] by -1
			_day[i] = if isNaN(parseInt(_day[i])) then 0 else parseInt(_day[i])
		for i in [_time.length - 1..0] by -1 
			_time[i] = if isNaN(parseInt(_time[i])) then 0 else parseInt(_time[i])
		_temp = new Date(_day[0],_day[1]-1,_day[2],_time[0],_time[1],_time[2])
		return _temp.getTime() / 1000
		
	_timeChange:(table,timeindex)->
		mydate = new Date()
		order = switch timeindex
			when 0#'All time'
				table
			when 1#'3 months'
				mydate.setMonth(mydate.getMonth()-3)
				(item for item in table when @strtotime(item.time) > mydate.getTime()/1000)
			when 2,3,4,5,6
				(item for item in table when !!~item.time.indexOf((mydate.getFullYear()-timeindex+2).toString()))
			when 8#'Cancel'
				(item for item in table when @strtotime(item.time) < mydate.getFullYear()-5)
		order
				
	_stateChange:(table,stateindex)->
		order = switch stateindex
			when 0#'All state'
				table
			when 1#'Contract'
				(item for item in table when item.stateid is 2)
			when 2#'Waiting for payment'
				(item for item in table when item.stateid in [3,9,12])
			when 3#'Picking'
				(item for item in table when item.stateid in [10] and item.transportid is 1)
			when 4#'Confirmt'
				(item for item in table when item.stateid in [11])
			when 5#'Finished'
				(item for item in table when item.stateid is 13)
			when 6#'Cancel'
				(item for item in table when item.stateid is 14)
		order
				
	_orderChange:->
		order = @_timeChange Order.all(),@item.options[1]
		@item.ordermap = @_stateChange order,@item.options[0]
		@render()
		
	timeChange:(e)=>
		@item.options[1] = parseInt $(e.target).val()
		@_orderChange()
		
	stateChange:(e)->
		@item.options[0] = parseInt $(e.target).val()
		@_orderChange()
		
module.exports = myOrders