Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')

$		= Spine.$

class CustomTrees extends Spine.Controller
	className: 'customtrees'
  
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

		@custom = $.Deferred()
		@person = $.Deferred()
		
		Custom.bind "refresh",=>@custom.resolve()
		Person.bind "refresh",=>
			return for citem in Custom.all() when not Person.exists citem.userid
			@person.resolve()

		Custom.bind "create",(item)=>
			parentId = @getRootId item.type
			childZNode = 
				"id":@getLeafId parentId,item
				"pId":parentId
				"name":item.getName()
			@addTreeNode childZNode

		Custom.bind "update",(item)=>
			if item?
				node = @zTree.getSelectedNodes()
				node[0].name = item.getName()
				@zTree.updateNode(node[0])
				@onTreeClick(null, @zTree.setting.treeId, node[0],1) #调用事件  


		Custom.bind "destroy",(item)=>
			parentId = @getRootId item.type
			childZNode = 
				"id":@getLeafId parentId,item
				"pId":parentId
				"name":item.getName()
			@zTree.removeNode(childZNode)

	getRootId:(type)->
		 if type is 'P' then 1 else 2
		 
	getLeafId:(rootId,item)->
		rootId*100000+parseInt(item.id,10)	
		
	addTreeNode:(childNode)=>
		parentZNode = @zTree.getNodeByParam("id", childNode.pId, null) #获取父节点
		@node = @zTree.addNodes(parentZNode[0], childNode, true)
		@zTree.selectNode(@node) #选择点
		@onTreeClick null,@zTree.setting.treeId,@node,1
  
	render: ->
		@nodes = ({id:key+1,pId:0,name:val} for val,key in ['个人','单位'])
		@nodes[1...1] = ({id:@getLeafId(@getRootId(item.type),item),pId:@getRootId(item.type),name:item.getName()} for item in Custom.all())
		@html require("views/customtrees")()
		$.fn.zTree.init($(@ztreeEl), @setting, @nodes)
		@zTree = $.fn.zTree.getZTreeObj("customTree") #获取ztree对象
		@node = @zTree.getNodeByParam?('id', @item.nodeid or 1) #获取id为1的点
		@zTree.selectNode(@node) #选择点
		#zTree.setting.callback.onClick(null, zTree.setting.treeId, node,1) #调用事件
		$(@buttonEl).button().click (event)=>
			@option(event)
	
	change: (params) =>
		try
			$.when( @custom,@person).done =>
				if params.id?
					id = parseInt params.id,10
					id += @getRootId(Custom.find(params.id).type)*100000 unless /\/customtype\//.test params.match[0]
				@item = 
					nodeid:id
					customs:Custom.all()
				@setting = 
					data: 
						simpleData: 
							enable: true
					callback: 
						beforeClick: @beforeTreeClick
						onClick: @onTreeClick

				@render()
		catch err
			@log "file: sysadmin.custom.tree.coffee\nclass: Customs\nerror: #{err.message}"
	beforeTreeClick:(treeId, treeNode, clickFlag)->
		#className = (className === "dark" ? "":"dark");
		#showLog("[ "+getTime()+" beforeClick ]&nbsp;&nbsp;" + treeNode.name );
		return (treeNode.click isnt false);

	getNodeInfo:()->
		if @node.id < 1000 then [@node.id,'/customtype',"客户类型"] else  [@node.id - @node.pId*100000,'/customs',"客户"] 

	onTreeClick:(event, treeId, treeNode, clickFlag)=>
		event?.stopPropagation()
		if clickFlag is 1
			$(@buttonEl).button  "option", "disabled", false
			@node = treeNode
			n = @getNodeInfo()
			@navigate(n[1],n[0],'show') 
		else
			$(@buttonEl)[1..].button  "option", "disabled", true 
			#@navigate('/customs/department',treeNode.id,'show') if treeNode.id < 1000
		#showLog("[ "+getTime()+" onClick ]&nbsp;&nbsp;clickFlag = " + clickFlag + " (" + (clickFlag===1 ? "普通选中": (clickFlag===0 ? "<b>取消选中</b>" : "<b>追加选中</b>")) + ")");
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
		n = @getNodeInfo()
		$(@buttonEl).each (index,item)=>
			if item.childNodes[0] is opt[0]
				switch index
					when 0 # add 
						@navigate("#{n[1]}/new")
					when 1 # edit 
						@navigate(n[1], n[0], 'edit') if n[0] > 0
					when 2 # delete 
						try
							throw "该节点有子节点，无法删除！" if @node.isParent
							@navigate(n[1], n[0], 'delete') if n[0] > 0
						catch err
							alert err
				title = ["添加", "编辑","删除"][index]
				$("body >header h2").text "经营管理->#{n[2]}管理->#{title}#{n[2]}"

module.exports = CustomTrees