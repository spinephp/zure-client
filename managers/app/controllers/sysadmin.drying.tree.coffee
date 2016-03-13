Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$

ManagerTree = require('controllers/main.tree')

class DryingTrees extends ManagerTree
	className: 'dryingtrees'
  
	constructor: ->
		super
		@active @change
		Drymain.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		@drymain = $.Deferred()

		Drymain.bind "refresh",=>@drymain.resolve()

		Drymain.bind "destroy",(item)=>
			parentId = 0
			childZNode = 
				"id":parseInt(item.id,10)
				"pId":parentId
				"name":item.starttime
			@zTree.removeNode(childZNode)
			
	render: ->
		@nodes = ({id:parseInt(item.id),pId:0,name:item.starttime} for item in @item.drymains)
		#@nodes[1...1] = ({id:parseInt(item.stateid)*100000+parseInt(item.id),pId:item.stateid,name:item.code} for item in @item.orders)
		@html require("views/dryingtrees")()
		@selectFirstNode "dryingTree"
	
	change: (params) =>
		try
			$.when( @drymain).done( =>
				unless params.id is '-1'
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

	getNodeInfo:(index)->
		[(if index is 1 then -1 else @node.id),'/dryings',"干燥"]
		
	getRootTitle:->
		"生产"

module.exports = DryingTrees

