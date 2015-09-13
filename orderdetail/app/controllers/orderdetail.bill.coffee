Spine   = require('spine')
Order = require('models/order')
Bill = require('models/bill')
Billfree = require('models/billfree')
Billsale = require('models/billsale')
Billcontent = require('models/billcontent')
Default = require('models/default')
$       = Spine.$

class Bills extends Spine.Controller
	className: 'bills'
  
	constructor: ->
		super
		@active @change
		
		@default = $.Deferred()
		@order= $.Deferred()
		@bill = $.Deferred()
		@billfree = $.Deferred()
		@billsale = $.Deferred()
		@billcontent = $.Deferred()
		Default.bind "refresh",=>@default.resolve()
		Order.bind "refresh",=>@order.resolve()
		Bill.bind "refresh",=>@bill.resolve()
		Billfree.bind "refresh",=>@billfree.resolve()
		Billsale.bind "refresh",=>@billsale.resolve()
		Billcontent.bind "refresh",=>@billcontent.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				#@item.currency = Currency.find @item.default.currencyid
				@render()
  
	render: =>
		@html require('views/showbill') @item
    
	change: (params) =>
		try
			$.when(@order,@bill,@billfree,@billsale,@billcontent,@default).done =>
				default1 = Default.first()
				order = Order.find $.getUrlParam "orderid"
				bill = Bill.find order.billtypeid
				content = Billcontent.find order.billcontentid
				billcur = if parseInt(bill.id) is 1 then Billfree.find order.billid else Billsale.find order.billid
				@item = 
					default:default1
					types:bill
					contents:content
					bills:billcur
				@render()
		catch err
			@log "file:ordertetail.product.coffee\nclass:Products\nerror: #{err.message}"
    
module.exports =  Bills