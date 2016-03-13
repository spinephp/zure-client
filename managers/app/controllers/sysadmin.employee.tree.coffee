Spine	= require('spine')
Department = require('models/department')
Employee = require('models/employee')

$		= Spine.$
ManagerTree = require('controllers/main.tree')

class EmployeeTrees extends ManagerTree
	className: 'employeetrees'
   
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
  
	render: ->
		@nodes = ({id:parseInt(item.id),pId:0,name:item.name} for item in Department.all())
		@nodes[1...1] = ({id:parseInt(item.departmentid)*100000+parseInt(item.id),pId:item.departmentid,name:item.getName()} for item in Employee.all())
		@html require("views/employeetrees")()
		@selectFirstNode "employeeTree"
	
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
			@log "file: sysadmin.employee.tree.coffee\nclass: Employees\nerror: #{err.message}"

	getNodeInfo:(index)->
		if @node.id < 1000 then [@node.id,'/department',"部门"] else  [@node.id - @node.pId*100000,'/employees',"员工"] 
		
	getRootTitle:->
		"劳资"

module.exports = EmployeeTrees