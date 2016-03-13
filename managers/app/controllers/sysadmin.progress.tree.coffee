Spine	= require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')

$		= Spine.$

ManagerTree = require('controllers/main.tree')

class ProgressTrees extends ManagerTree
	className: 'progresstrees'
  
	constructor: ->
		super
		@active @change
		Orderstate.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		@order = $.Deferred()
		@orderstate = $.Deferred()

		Order.bind "refresh",=>@order.resolve()
		Orderstate.bind "refresh",=>@orderstate.resolve()

	render: ->
		@nodes = ({id:parseInt(item.id),pId:0,name:item.name} for item in @item.orderstates)
		@nodes[1...1] = ({id:parseInt(item.stateid)*100000+parseInt(item.id),pId:item.stateid,name:item.code} for item in @item.orders)
		@html require("views/progresstrees")()
		@selectFirstNode "progressTree"
	
	change: (params) =>
		try
			$.when( @order,@orderstate).done( =>
				if params.id?
					id = parseInt params.id,10
					#id += Order.find(params.id).stateid*100000 unless /\/orderstate/.test params.match[0]
				@item = 
					nodeid:id
					orderstates:Orderstate.select (item)-> return parseInt(item.id,10) in [4..8]
					orders:Order.select (item)-> return parseInt(item.stateid,10) in [4..8]
				@setting = 
					data: 
						simpleData: 
							enable: true
					callback: 
						beforeClick: @beforeTreeClick
						onClick: @onTreeClick

				@render()
			)
		catch err
			@log "file: sysadmin.progress.coffee\nclass: Progresss\nerror: #{err.message}"

	getNodeInfo:(index)->
		if @node.id < 1000 then [@node.id,'/progress/state',"进度状态"] else  [@node.id - @node.pId*100000,'/progress',"进度"] 
		
	getRootTitle:->
		"生产"

module.exports = ProgressTrees