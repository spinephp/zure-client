Spine   = require('spine')

$       = Spine.$

ShowOrderstates = require('controllers/sysadmin.order.option.stateshow')
NewOrderstates = require('controllers/sysadmin.order.option.stateadd')
EditOrderstates = require('controllers/sysadmin.order.option.stateedit')
DeleteOrderstates = require('controllers/sysadmin.order.option.statedelete')

#ShowOrders = require('controllers/sysadmin.order.option.show')
NewOrders = require('controllers/sysadmin.order.option.add')
EditOrders = require('controllers/sysadmin.order.option.edit')
DeleteOrders = require('controllers/sysadmin.order.option.delete')

class OrderOption extends Spine.Stack
	className: 'orderoption stack'
	
	controllers:
		stateshow: ShowOrderstates
		stateadd: NewOrderstates
		stateedit: EditOrderstates
		#ordershow: ShowOrders
		orderadd: NewOrders
		orderedit: EditOrders
		orderdelete: DeleteOrders
		classdelete: DeleteOrderstates
	
module.exports = OrderOption