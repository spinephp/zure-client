Spine	= require('spine')

$		= Spine.$

class ManagerTrees extends Spine.Controller
  
	elements:
		"button":"buttonEl"
		'tr .rowselected':'selectedEl'
		'tr':'trEl'
		'ul':'ztreeEl'
  
	events:
		'click button': 'option'
		'click tr': 'userSelect'
		 
	getLeafId:(rootId,item)->
		rootId*100000+parseInt(item.id,10)	
		
	addTreeNode:(childNode)=>
		parentZNode = @zTree.getNodeByParam("id", childNode.pId, null) #获取父节点
		@node = @zTree.addNodes(parentZNode[0], childNode, true)
		@zTree.selectNode(@node) #选择点
		@onTreeClick null,@zTree.setting.treeId,@node,1
		
	selectFirstNode:(treeid)->
		$.fn.zTree.init($(@ztreeEl), @setting, @nodes)
		@zTree = $.fn.zTree.getZTreeObj(treeid) #获取ztree对象
		@node = @zTree.getNodeByParam?('id', @item.nodeid or 1) #获取id为1的点
		@zTree.selectNode(@node) #选择点
		#zTree.setting.callback.onClick(null, zTree.setting.treeId, node,1) #调用事件
		$(@buttonEl).button().click (event)=>
			@option(event)

	beforeTreeClick:(treeId, treeNode, clickFlag)->
		#className = (className === "dark" ? "":"dark");
		#showLog("[ "+getTime()+" beforeClick ]&nbsp;&nbsp;" + treeNode.name );
		return (treeNode.click isnt false);

	getNodeInfo:(index)->
		['','','']

	onTreeClick:(event, treeId, treeNode, clickFlag)=>
		event?.stopPropagation()
		if clickFlag is 1
			$(@buttonEl).button  "option", "disabled", false
			@node = treeNode
			n = @getNodeInfo()
			@navigate(n[1],n[0],'show') 
			rTitle = @getRootTitle()
			$("body >header h2").text "#{rTitle}管理->#{n[2]}管理->#{n[2]}信息"
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

	getRootTitle:->
		"站点"
		
	option: (e)=>
		opt = $(e.target)
		$(@buttonEl).each (index,item)=>
			if item.childNodes[0] is opt[0]
				n = @getNodeInfo index
				switch index
					when 0 # add 
						@navigate("#{n[1]}/new")
					when 1 # edit 
						@navigate(n[1], n[0],  if n[0] > 0 then 'edit' else 'show')
					when 2 # delete 
						try
							throw "该节点有子节点，无法删除！" if @node.isParent
							@navigate(n[1], n[0], 'delete') if n[0] > 0
						catch err
							alert err
				title =$(opt[0]).text()
				rTitle = @getRootTitle()
				$("body >header h2").text "#{rTitle}管理->#{n[2]}管理->#{title}#{n[2]}"

module.exports = ManagerTrees