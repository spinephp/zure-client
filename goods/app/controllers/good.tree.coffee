Spine	= require('spine')
Goodclass = require('models/goodclass')
Good = require('models/good')
Default = require('models/default')

$		= Spine.$

class GoodTrees extends Spine.Controller
	className: 'goodtrees'
  
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
		Goodclass.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		@good = $.Deferred()
		@goodclass = $.Deferred()
		@default = $.Deferred()

		Good.bind "refresh",=>@good.resolve()
		Goodclass.bind "refresh",=>@goodclass.resolve()
		Default.bind "refresh",=>@default.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()

	addTreeNode:(childNode)=>
		parentZNode = @zTree.getNodeByParam("id", childNode.pId, null) #获取父节点
		@node = @zTree.addNodes(parentZNode[0], childZNode, true)
		@zTree.selectNode(@node) #选择点
		@onTreeClick null,@zTree.setting.treeId,@node,1

	render: ->
		@nodes = ({id:parseInt(item.id),pId:item.parentid,name:@item.default.translates item.names} for item in Goodclass.all())
		@nodes[1...1] = ({id:parseInt(item.classid)*100000+parseInt(item.id),pId:item.classid,name:item.size} for item in Good.all())
		@html require("views/goodtrees")(@item)
		$.fn.zTree.init($(@ztreeEl), @setting, @nodes)
		@zTree = $.fn.zTree.getZTreeObj("treeDemo") #获取ztree对象
		@node = @zTree.getNodeByParam?('id', @item.nodeid or 1) #获取id为1的点
		@zTree.selectNode(@node) #选择点
		#@zTree.setting.callback.onClick(null, @zTree.setting.treeId, @node,1) #调用事件
		$(@buttonEl).button().click (event)=>
			@option(event)
	
	change: (params) =>
		try
			$.when( @good,@goodclass,@default).done( =>
				id = parseInt params.id,10
				id += Good.find(params.id).classid*100000 unless /\/goodclass/.test params.match[0]
				@item = 
					nodeid:id
					default:Default.first()
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
			@log "file: sysadmin.good.coffee\nclass: Goods\nerror: #{err.message}"
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
				name = 'class'
			else
				name = null
				id -= parseInt(treeNode.pId,10)*100000
			@navigate('/good',id,name) 
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
		if @node.id < 1000
			name = '/goods/class'
			id = @node.id
		else
			name = '/goods'
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

module.exports = GoodTrees