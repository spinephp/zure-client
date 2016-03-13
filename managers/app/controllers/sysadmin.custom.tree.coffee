Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')

$		= Spine.$
ManagerTree = require('controllers/main.tree')

class CustomTrees extends ManagerTree
	className: 'customtrees'
  
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
  
	render: ->
		@nodes = ({id:key+1,pId:0,name:val} for val,key in ['个人','单位'])
		@nodes[1...1] = ({id:@getLeafId(@getRootId(item.type),item),pId:@getRootId(item.type),name:item.getName()} for item in Custom.all())
		@html require("views/customtrees")()
		@selectFirstNode "customTree"
	
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

	getNodeInfo:(index)->
		if @node.id < 1000 then [@node.id,'/customtype',"客户类型"] else  [@node.id - @node.pId*100000,'/customs',"客户"] 
		
	getRootTitle:->
		"经营"
		
module.exports = CustomTrees