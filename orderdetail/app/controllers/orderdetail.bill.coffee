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
		Order.bind('refresh change', @render)
		Bill.bind('refresh change', @render)
		Billfree.bind('refresh change', @render)
		Billsale.bind('refresh change', @render)
		Billcontent.bind('refresh change', @render)
  
	render: =>
		try
			if Order.count() and Bill.count() and Billfree.count() and Billsale.count() and Billcontent.count()
				order = Order.first()
				bill = Bill.find order.billtypeid
				content = Billcontent.find order.billcontentid
				curbill = if bill.id is 1 then Billfree else Billsale
				billcur = curbill.find order.billid
				@html require('views/showbill')({types:bill,contents:content,bills:billcur})
		catch err
			console.log err.message
    
	change: (params) =>
		@render()
    
module.exports =  Bills