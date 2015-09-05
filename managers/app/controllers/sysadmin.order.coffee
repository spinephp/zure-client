Spine   = require('spine')
Manager = require('spine/lib/manager')
$       = Spine.$
Orderstate = require('models/orderstate')
OrderPerson = require('models/orderperson')
Order = require('models/order')
Province = require('models/province')
Consignee = require('models/consignee')
Bill = require('models/bill')
Billcontent = require('models/billcontent')
Billfree = require('models/billfree')
Billsale = require('models/billsale')
Payment = require('models/payment')
Transport = require('models/transport')

Option    = require('controllers/sysadmin.order.option')
Tree = require('controllers/sysadmin.order.tree')

class Orders extends Spine.Controller
	className: 'orders'
  
	constructor: ->
		super
			
		@tree = new Tree
		@option    = new Option

		Order.bind "refresh",=>
			if Order.count() > 0
				Consignee.fetch @buildParams "consigneeid",Consignee.attributes
				OrderPerson.fetch @buildParams "userid",OrderPerson.attributes
				Province.fetch() if Province.count() is 0
				#Product.fetch()
				Bill.fetch()
				Billcontent.fetch()
				Billfree.fetch()
				Billsale.fetch()
				Payment.fetch()
				Transport.fetch()

		#Spine.bind "userlogined",(user)->
			
		@routes
			'/orderstate/new': (params) -> 
				@active(params)
				@tree.active(params)
				@option.stateadd.active(params)
			'/orderstate/:id/show': (params) -> 
				@active(params)
				@tree.active(params)
				@option.stateshow.active(params)
			'/orderstate/:id/edit': (params) -> 
				@active(params)
				@tree.active(params)
				@option.stateedit.active(params)
			'/orderstate/:id/delete': (params) -> 
				@active(params)
				@tree.active(params)
				@option.statedelete.active(params)
			'/orders/new': (params) -> 
				@active(params)
				@tree.active(params)
				@option.orderadd.active(params)
			'/orders/:id/show': (params) -> 
				@active(params)
				@tree.active(params)
				@option.orderedit.active(params)
			'/orders/:id/edit': (params) -> 
				@active(params)
				@tree.active(params)
				@option.orderedit.active(params)
			'/orders/:id/delete': (params) -> 
				@active(params)
				@tree.active(params)
				@option.orderdelete.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		@navigate('/orderstate',1,'show')

	buildParams: (keyid,fields) ->
		ids = []
		i = 0
		ids[i++] = order[keyid] for order in Order.all() when order[keyid] not in ids
		condition = [{field:"id",value:ids,operator:"in"}]
		params =
			data:{ cond:condition,filter: fields, token: $.fn.cookie('PHPSESSID') } 
			processData: true
    
module.exports = Orders