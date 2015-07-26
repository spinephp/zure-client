Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$

class DryingTrees extends Spine.Controller
	className: 'dryingtrees'
  
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
		Drymain.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		@drymain = $.Deferred()

		Drymain.bind "refresh",=>@drymain.resolve()

	addTreeNode:(childNode)=>
		parentZNode = @zTree.getNodeByParam("id", childNode.pId, null) #获取父节点
		@node = @zTree.addNodes(parentZNode[0], childZNode, true)
		#@zTree.selectNode(@node) #选择点
		#@onTreeClick null,@zTree,@node,1

	render: ->
		@nodes = ({id:parseInt(item.id),pId:0,name:item.starttime} for item in @item.drymains)
		#@nodes[1...1] = ({id:parseInt(item.stateid)*100000+parseInt(item.id),pId:item.stateid,name:item.code} for item in @item.orders)
		@html require("views/dryingtrees")()
		$.fn.zTree.init($(@ztreeEl), @setting, @nodes)
		@zTree = $.fn.zTree.getZTreeObj("dryingTree") #获取ztree对象
		if @item.nodeid > 0
			@node = @zTree.getNodeByParam?('id', @item.nodeid or 4) #获取id为1的点
			@zTree.selectNode(@node) #选择点
		#zTree.setting.callback.onClick(null, zTree.setting.treeId, node,1) #调用事件
		$(@buttonEl).button().click (event)=>
			@option(event)
	
	change: (params) =>
		try
			$.when( @drymain).done( =>
				if params.id?
					id = parseInt params.id,10
				@item = 
					nodeid:id
					drymains:Drymain.select (item)-> return parseInt(item.state,10) isnt 0
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
			@log "file: sysadmin.drying.coffee\nclass: Dryings\nerror: #{err.message}"
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
			@navigate('/dryings',id,'show') 
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
		opt = $(e.target)
		id = @node.id
		$(@buttonEl).each (index,item)=>
			if item.childNodes[0] is opt[0]
				name = '/dryings'
				switch index
					when 0 # edit 
						@navigate(name, 0, 'edit')
					when 1 # delete 
						try
							throw "该节点有子节点，无法删除！" if @node.isParent
							@navigate(name, id, 'delete') if id > 0
						catch err
							alert err

module.exports = DryingTrees

