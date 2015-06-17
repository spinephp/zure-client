Spine   = require('spine')
Manager = require('spine/lib/manager')
$       = Spine.$
Orderstate = require('models/orderstate')
Ordersstate = require('models/ordersstate')
OrderPerson = require('models/orderperson')
Order = require('models/order')

Figures = require('controllers/sysadmin.dryingview.figure')
Headers = require('controllers/sysadmin.dryingview.header)
Datas = require('controllers/sysadmin.dryingview.data')

class Dryingview extends Spine.Controller
	className: 'dryingview'
   
	constructor: ->
		super
		@active @change
	
		@figures    = new Figures
		@headers    = new Headers
		@datas      = new Datas
	
		@append @headers,@figures,@datas

	change: (params) ->
		@infomations.active params
		@progressbars.active params
		@products.active params
 
module.exports = Dryingview