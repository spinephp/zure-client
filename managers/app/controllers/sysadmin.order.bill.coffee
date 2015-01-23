Spine   = require('spine')
Order = require('models/order')
Bill = require('models/bill')
Billfree = require('models/billfree')
Billsale = require('models/billsale')
Billcontent = require('models/billcontent')
$       = Spine.$

class Bills extends Spine.Controller
	className: 'bills'
  
	constructor: ->
		super
		@active @change

		@order = $.Deferred()
		@bill = $.Deferred()
		@billfree = $.Deferred()
		@billsale = $.Deferred()
		@billcontent = $.Deferred()

		Order.bind "refresh",=>@order.resolve()
		Bill.bind "refresh",=>@bill.resolve()
		Billfree.bind 'refresh change',=>@billfree.resolve()
		Billsale.bind 'refresh change',=>@billsale.resolve()
		Billcontent.bind 'refresh change',=>@billcontent.resolve()
  
	render: =>
		@html require('views/orderbill')(@item)
    
	change: (params) =>
		try
			$.when( @order,@bill,@billfree,@billsale,@billcontent).done =>
				if Order.exists params.id
					order = Order.find params.id
					bill = Bill.find order.billtypeid
					curbill = if bill.id is 1 then Billfree else Billsale
					@item = 
						types:bill
						contents:Billcontent.find order.billcontentid
						bills:curbill.find order.billid
					@render()
		catch err
			@log "file: sysadmin.order.bill.coffee\nclass: Bills\nerror: #{err.message}"
    
module.exports =  Bills