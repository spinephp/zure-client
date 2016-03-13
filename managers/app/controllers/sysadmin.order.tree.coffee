Spine	= require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')
OrderPerson = require('models/orderperson')

$		= Spine.$
ManagerTree = require('controllers/main.tree')

class OrderTrees extends ManagerTree 
	className: 'ordertrees'
  
	constructor: ->
		super
		@active @change
		Orderstate.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		@order = $.Deferred()
		@orderstate = $.Deferred()
		@person = $.Deferred()

		Order.bind "refresh",=>@order.resolve()
		Orderstate.bind "refresh",=>@orderstate.resolve()
		OrderPerson.bind "refresh",=>@person.resolve()

		Order.bind "create",(item)=>
			parentId = parseInt item.stateid,10
			childZNode = 
				"id":parentId*100000+parseInt(item.id,10)
				"pId":parentId
				"name":item.size()
			@addTreeNode childZNode

		Orderstate.bind "create",(item)=>
			parentId = 0
			childZNode = 
				"id":item.id
				"pId":item.parentid
				"name":item.name
			@addTreeNode childZNode

		Orderstate.bind "update",(item)=>
			if item?
				node = @zTree.getSelectedNodes()
				node[0].name = item.name
				@zTree.updateNode(node[0])
				@onTreeClick(null, @zTree.setting.treeId, node[0],1) #调用事件  

		Order.bind "destroy",(item)=>
			parentId = parseInt item.stateid,10
			childZNode = 
				"id":parentId*100000+parseInt(item.id,10)
				"pId":parentId
				"name":item.size()
			@zTree.removeNode(childZNode)

		Orderstate.bind "destroy",(item)=>
			parentId = 0
			childZNode = 
				"id":item.id
				"pId":item.parentid
				"name":item.name
			@zTree.removeNode(childZNode)

	render: ->

		# 订单状态节点
		@nodes = ({id:parseInt(item.id),pId:0,name:item.name} for item in @item.orderstates)

		# 订单结点
		@nodes[1...1] = ({id:parseInt(item.stateid)*100000+parseInt(item.id),pId:item.stateid,name:item.customName()+' '+item.code} for item in Order.all())
		@html require("views/ordertrees")()
		@selectFirstNode "orderTree"
	
	change: (params) =>
		try
			$.when( @order,@orderstate,@person).done( =>
				if params.id?
					id = parseInt params.id,10
					id += Order.find(params.id).stateid*100000 unless /\/orderstate/.test params.match[0]
				@item = 
					nodeid:id
					orderstates:Orderstate.all()
					orders:Order.all()
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
			@log "file: sysadmin.order.coffee\nclass: Orders\nerror: #{err.message}"

	getNodeInfo:(index)->
		if @node.id < 1000 then [@node.id,'/orderstate',"订单状态",false] else  [@node.id - @node.pId*100000,'/orders',"订单",@node.pId in [4..8]] 

	getRootTitle:->
		"经营"

module.exports = OrderTrees