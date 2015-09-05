Spine	= require('spine')
Department = require('models/department')
Employee = require('models/employee')

$		= Spine.$

class EmployeeTrees extends Spine.Controller
	className: 'employeetrees'
  
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
		Department.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText

		@employee = $.Deferred()
		@department = $.Deferred()
		
		Employee.bind "refresh",=>@employee.resolve()
		Department.bind "refresh",=>@department.resolve()

		Employee.bind "create",(item)=>
			parentId = parseInt item.departmentid,10
			childZNode = 
				"id":parentId*100000+parseInt(item.id,10)
				"pId":parentId
				"name":item.getName()
			@addTreeNode childZNode

		Employee.bind "update",(item)=>
			if item?
				node = @zTree.getSelectedNodes()
				node[0].name = item.getName()
				@zTree.updateNode(node[0])
				@onTreeClick(null, @zTree.setting.treeId, node[0],1) #调用事件  

		Department.bind "create",(item)=>
			childZNode = 
				"id":item.id
				"pId":0
				"name":item.name
			@addTreeNode childZNode

		Department.bind "update",(item)=>
			if item?
				node = @zTree.getSelectedNodes()
				node[0].name = item.name
				@zTree.updateNode(node[0])
				@onTreeClick(null, @zTree.setting.treeId, node[0],1) #调用事件  

		Employee.bind "destroy",(item)=>
			parentId = parseInt item.departmentid,10
			childZNode = 
				"id":parentId*100000+parseInt(item.id,10)
				"pId":parentId
				"name":item.getName()
			@zTree.removeNode(childZNode)

		Department.bind "destroy",(item)=>
			childZNode = 
				"id":item.id
				"pId":0
				"name":item.name
			@zTree.removeNode(childZNode)

	addTreeNode:(childNode)=>
		parentZNode = @zTree.getNodeByParam("id", childNode.pId, null) #获取父节点
		@node = @zTree.addNodes(parentZNode[0], childNode, true)
		@zTree.selectNode(@node) #选择点
		@onTreeClick null,@zTree.setting.treeId,@node,1
  
	render: ->
		@nodes = ({id:parseInt(item.id),pId:0,name:item.name} for item in Department.all())
		@nodes[1...1] = ({id:parseInt(item.departmentid)*100000+parseInt(item.id),pId:item.departmentid,name:item.getName()} for item in Employee.all())
		@html require("views/employeetrees")()
		$.fn.zTree.init($(@ztreeEl), @setting, @nodes)
		@zTree = $.fn.zTree.getZTreeObj("employeeTree") #获取ztree对象
		@node = @zTree.getNodeByParam?('id', @item.nodeid or 1) #获取id为1的点
		@zTree.selectNode(@node) #选择点
		#zTree.setting.callback.onClick(null, zTree.setting.treeId, node,1) #调用事件
		$(@buttonEl).button().click (event)=>
			@option(event)
	
	change: (params) =>
		try

			$.when( @employee,@department).done =>
				if params.id?
					id = parseInt params.id,10
					id += Employee.find(params.id).departmentid*100000 unless /\/department\//.test params.match[0]
				@item = 
					nodeid:id
					employees:Employee.all()
					departments:Department.all()
				@setting = 
					data: 
						simpleData: 
							enable: true
					callback: 
						beforeClick: @beforeTreeClick
						onClick: @onTreeClick

				@render()
		catch err
			@log "file: sysadmin.employee.coffee\nclass: Employees\nerror: #{err.message}"
	beforeTreeClick:(treeId, treeNode, clickFlag)->
		#className = (className === "dark" ? "":"dark");
		#showLog("[ "+getTime()+" beforeClick ]&nbsp;&nbsp;" + treeNode.name );
		return (treeNode.click isnt false);

	onTreeClick:(event, treeId, treeNode, clickFlag)=>
		event.stopPropagation() if event?
		if clickFlag is 1
			$(@buttonEl).button  "option", "disabled", false
			@node = treeNode
			id = parseInt treeNode.id,10

			if id < 1000
				name = '/department'
			else
				name = '/employees'
				id -= parseInt(treeNode.pId)*100000
			@navigate(name,id,'show') 
		else
			$(@buttonEl)[1..].button  "option", "disabled", true 
			#@navigate('/employees/department',treeNode.id,'show') if treeNode.id < 1000
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
		if @node.id < 1000
			name = '/department'
			id = @node.id
		else
			name = '/employees'
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

module.exports = EmployeeTrees