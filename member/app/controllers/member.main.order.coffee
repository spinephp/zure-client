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
			values[i++] = pro.proid for pro in rec.products when pro.proid not in values for rec in Order.all()
			Orderproduct.append values if i > 0

			fields = Consignee.attributes
			values = []
			i = 0
			values[i++] = rec.consigneeid for rec in Order.all() when rec.consigneeid not in values
			condition = [{field:"id",value:values,operator:"in"}]
			params = 
				data:{ cond:condition,filter: fields, token: sessionStorage.token } 
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
		
	timeChange:(e)->
		@item.options[1] = parseInt $(e.target).val()
		switch @item.options[1]
			when 0#'All time'
				@item.ordermap = Order.all()
			when 1#'3 months'
				@item.ordermap = Order.select (item)->item.time < strtotime("-90 days")
			when 2#'This year'
				@item.ordermap = Order.select (item)->item.time in [3,9,12]
			when 3#'Picking'
				@item.ordermap = Order.select (item)->item.time in [3,9,12]
			when 4#'Confirmt'
				@item.ordermap = Order.select (item)->item.time in [3,9,12]
			when 5#'Finished'
				@item.ordermap = Order.select (item)->item.time is 13
			when 6#'Cancel'
				@item.ordermap = Order.select (item)->item.time is 14
		@render()
		
	stateChange:(e)->
		@item.options[0] = parseInt $(e.target).val()
		switch @item.options[0]
			when 0#'All state'
				@item.ordermap = Order.all()
			when 1#'Contract'
				@item.ordermap = Order.select (item)->item.stateid is 2
			when 2#'Waiting for payment'
				@item.ordermap = Order.select (item)->item.stateid in [3,9,12]
			when 3#'Picking'
				@item.ordermap = Order.select (item)->item.stateid in [3,9,12]
			when 4#'Confirmt'
				@item.ordermap = Order.select (item)->item.stateid in [3,9,12]
			when 5#'Finished'
				@item.ordermap = Order.select (item)->item.stateid is 13
			when 6#'Cancel'
				@item.ordermap = Order.select (item)->item.stateid is 14
		@render()
		
module.exports = myOrders