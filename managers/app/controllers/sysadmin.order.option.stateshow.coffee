Spine	= require('spine')
Orderstate = require('models/orderstate')

$		= Spine.$

class OrderstateShows extends Spine.Controller
	className: 'orderstateshows'
  
	constructor: ->
		super
		@active @change
		Orderstate.bind "refresh",=>@change
  
	render: ->
		@html require("views/orderstate")(@item)
		$("body >header h2").text "经营管理->订单管理->订单状态信息"
	
	change: (params) =>
		try
			if Orderstate.exists params.id
				@item = 
					orderstate:Orderstate.find params.id
				@render()
		catch err
			@log "file: sysadmin.main.order.option.statehow.coffee\nclass: OrderstateShows\nerror: #{err.message}"

module.exports = OrderstateShows