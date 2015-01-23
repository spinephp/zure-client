Spine	= require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')

$		= Spine.$

class ProgressTrees extends Spine.Controller
	className: 'progresstrees'
  
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

		Order.bind "refresh",=>@order.resolve()
		Orderstate.bind "refresh",=>@orderstate.resolve()

	addTreeNode:(childNode)=>
		parentZNode = @zTree.getNodeByParam("id", childNode.pId, null) #获取父节点
		@node = @zTree.addNodes(parentZNode[0], childZNode, true)
		#@zTree.selectNode(@node) #选择点
		#@onTreeClick null,@zTree,@node,1

	render: ->
		@nodes = ({id:parseInt(item.id),pId:0,name:item.name} for item in @item.orderstates)
		@nodes[1...1] = ({id:parseInt(item.stateid)*100000+parseInt(item.id),pId:item.stateid,name:item.code} for item in @item.orders)
		@html require("views/progresstrees")()
		$.fn.zTree.init($(@ztreeEl), @setting, @nodes)
		@zTree = $.fn.zTree.getZTreeObj("progressTree") #获取ztree对象
		@node = @zTree.getNodeByParam?('id', @item.nodeid or 4) #获取id为1的点
		@zTree.selectNode(@node) #选择点
		#zTree.setting.callback.onClick(null, zTree.setting.treeId, node,1) #调用事件
		$(@buttonEl).button().click (event)=>
			@option(event)
	
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
			$(@buttonEl).button  "option", "disabled", false
			@node = treeNode
			id = parseInt treeNode.id,10

			if id < 1000
				name = '/progress/state'
			else
				name = '/progress'
				id -= parseInt(treeNode.pId,10)*100000
			@navigate(name,id,'show') 
		else
			$(@buttonEl)[1..].button  "option", "disabled", true 

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
		if @node.id < 1000
			name = '/progress/state'
			id = @node.id
		else
			name = '/progress'
			id = @node.id - @node.pId*100000
		@navigate(name, id, 'edit') if id > 0

module.exports = ProgressTrees