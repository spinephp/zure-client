Spine	= require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')
OrderPerson = require('models/orderperson')

$		= Spine.$

class OrderTrees extends Spine.Controller
	className: 'ordertrees'
  
	elements:
		"button":"buttonEl"
		'tr .rowselected':'selectedEl'
		'tr':'trEl'
		'ul':'ztreeEl'
  
	events:
		'click button': 'option'
		'click tr': 'userSelect'
  
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

	addTreeNode:(childNode)=>
		parentZNode = @zTree.getNodeByParam("id", childNode.pId, null) #获取父节点
		@node = @zTree.addNodes(parentZNode[0], childZNode, true)
		#@zTree.selectNode(@node) #选择点
		#@onTreeClick null,@zTree,@node,1

	render: ->

		# 订单状态节点
		@nodes = ({id:parseInt(item.id),pId:0,name:item.name} for item in @item.orderstates)

		# 订单结点
		@nodes[1...1] = ({id:parseInt(item.stateid)*100000+parseInt(item.id),pId:item.stateid,name:item.customName()+' '+item.code} for item in Order.all())
		@html require("views/ordertrees")()
		$.fn.zTree.init($(@ztreeEl), @setting, @nodes)
		@zTree = $.fn.zTree.getZTreeObj("orderTree") #获取ztree对象
		@node = @zTree.getNodeByParam?('id', @item.nodeid or 1) #获取id为1的点
		@zTree.selectNode(@node) #选择点
		#zTree.setting.callback.onClick(null, zTree.setting.treeId, node,1) #调用事件

		# 设置新建、编辑和删除按键状态
		$(@buttonEl).button(disabled: false).click (event)=>
			@option(event)
	
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
	beforeTreeClick:(treeId, treeNode, clickFlag)->
		#className = (className === "dark" ? "":"dark");
		#showLog("[ "+getTime()+" beforeClick ]&nbsp;&nbsp;" + treeNode.name );
		return (treeNode.click isnt false);

	# 处理树节点点击事件
	# clickFlag - 整数，指定选中类型 
	#             0 - 取消选中
	#             1 - 普通选中
	#             >1 - 追加选中
	onTreeClick:(event, treeId, treeNode, clickFlag)=>
		event.stopPropagation() if event?
		if clickFlag is 1
			@node = treeNode
			id = parseInt treeNode.id,10
			btnDisabled =  false

			if id < 1000
				name = '/orderstate'
			else
				name = '/orders'
				pId = parseInt treeNode.pId,10
				id -= pId*100000
				btnDisabled = (pId in [4..8])
			$(@buttonEl)[1..].button disabled:btnDisabled

			@navigate(name,id,'show') 
		else
			$(@buttonEl)[1..].button disabled:true 

	userSelect:(e)->
		e.stopPropagation()
		$(@trEl).removeClass 'rowselected'
		$(e.target).parent().addClass 'rowselected'
	
	getChildren:(ids,treeNode)->
		ids.push treeNode.id
		if treeNode.isParent
			for obj in treeNode.children
				@getChildren ids,treeNode.children[obj]
		return ids;

	option: (e)=>
		e.stopPropagation()
		opt = $(e.target)
		if @node.id < 1000
			name = '/orderstate'
			id = @node.id
		else
			name = '/orders'
			id = @node.id - @node.pId*100000
		$(@buttonEl).each (index,item)=>
			if item.childNodes[0] is opt[0]
				switch index
					when 0 # add 
						@navigate("#{name}/new")
					when 1 # edit 
						@navigate(name, id, 'edit') if id > 0
					when 2 # delete 
						try
							throw "该节点有子节点，无法删除！" if @node.isParent
							@navigate(name, id, 'delete') if id > 0
						catch err
							alert err

module.exports = OrderTrees