Spine	= require('spine')
Goodclass = require('models/goodclass')
Good = require('models/good')

$		= Spine.$
ManagerTree = require('controllers/main.tree')

class GoodTrees extends ManagerTree
	className: 'goodtrees'
  
	constructor: ->
		super
		@active @change
		Goodclass.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		@good = $.Deferred()
		@goodclass = $.Deferred()

		Good.bind "refresh",=>@good.resolve()
		Goodclass.bind "refresh",=>@goodclass.resolve()

		Good.bind "create",(item)=>
			parentId = parseInt item.classid,10
			childZNode = 
				"id":parentId*100000+parseInt(item.id,10)
				"pId":parentId
				"name":item.size()
			@addTreeNode childZNode

		Good.bind "update",(item)=>
			if item?
				node = @zTree.getSelectedNodes()
				node[0].name = item.size()
				@zTree.updateNode(node[0])
				@onTreeClick(null, @zTree.setting.treeId, node[0],1) #调用事件  

		Goodclass.bind "create",(item)=>
			parentId = parseInt item.classid,10
			childZNode = 
				"id":item.id
				"pId":item.parentid
				"name":item.name
			@addTreeNode childZNode

		Goodclass.bind "update",(item)=>
			if item?
				node = @zTree.getSelectedNodes()
				node[0].name = item.name
				@zTree.updateNode(node[0])
				@onTreeClick(null, @zTree.setting.treeId, node[0],1) #调用事件  

		Good.bind "destroy",(item)=>
			parentId = parseInt item.classid,10
			childZNode = 
				"id":parentId*100000+parseInt(item.id,10)
				"pId":parentId
				"name":item.size()
			@zTree.removeNode(childZNode)

		Goodclass.bind "destroy",(item)=>
			parentId = parseInt item.classid,10
			childZNode = 
				"id":item.id
				"pId":item.parentid
				"name":item.name
			@zTree.removeNode(childZNode)

	render: ->
		@nodes = ({id:parseInt(item.id),pId:item.parentid,name:item.name} for item in Goodclass.all())
		@nodes[1...1] = ({id:parseInt(item.classid)*100000+parseInt(item.id),pId:item.classid,name:item.size()} for item in Good.all())
		@html require("views/goodtrees")()
		@selectFirstNode "treeDemo"
	
	change: (params) =>
		try
			$.when( @good,@goodclass).done( =>
				if params.id?
					id = parseInt params.id,10
					id += Good.find(params.id).classid*100000 unless /\/goodclass/.test params.match[0]
				@item = 
					nodeid:id
					goods:Goodclass.all()
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

	getNodeInfo:(index)->
		if @node.id < 1000 then [@node.id,'/goodclass',"产品类型"] else  [@node.id - @node.pId*100000,'/goods',"产品"] 

	getRootTitle:->
		"经营"

module.exports = GoodTrees