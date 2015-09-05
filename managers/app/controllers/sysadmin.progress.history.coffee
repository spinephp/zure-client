Spine   = require('spine')
Order = require('models/order')
Orderstate   = require('models/orderstate')
Ordersstate   = require('models/ordersstate')
$       = Spine.$

class ProgressHistorys extends Spine.Controller
	className: 'progresshistorys'

	constructor: ->
		super
		@active @change

		@states = $.Deferred()
		@status = $.Deferred()

		Orderstate.bind "refresh",=>@states.resolve()
		Ordersstate.bind "refresh",=>@status.resolve()

	render: =>
		@html require('views/progresshistory')(@item)
	
	change: (params) =>
		try
			$.when( @states,@status).done =>
				order = Order.find params.id
				@item = 
					states:Orderstate.select (state)-> parseInt(state.id,10) in [4..8]
					status:Ordersstate.select (item)=>parseInt(item.orderid,10) is parseInt(order.id,10) and parseInt(item.stateid,10) in [4..8]
				@render()
		catch err
			@log "file: sysadmin.progress.history.coffee\nclass: ProgressHistorys\nerror: #{err.message}"
module.exports = ProgressHistorys