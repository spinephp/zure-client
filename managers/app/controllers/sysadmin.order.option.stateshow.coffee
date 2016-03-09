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
		title = if $(@el).closest().is("form") then "删除" else "信息"
		$("body >header h2").text "经营管理->订单管理->订单状态#{title}"
	
	change: (params) =>
		try
			if Orderstate.exists params.id
				@item = 
					orderstate:Orderstate.find params.id
				@render()
		catch err
			@log "file: sysadmin.main.order.option.statehow.coffee\nclass: OrderstateShows\nerror: #{err.message}"

	getItem:->
		@item

module.exports = OrderstateShows