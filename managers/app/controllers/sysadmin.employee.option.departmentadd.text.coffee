Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

class DepartmentAddTexts extends Spine.Controller
	className: 'textoption'
 
	elements:
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
  
	constructor: ->
		super
		@token = $.fn.cookie('PHPSESSID')
		@active @change

		@department = $.Deferred()
		
		Department.bind "refresh",=>@department.resolve()
  
	render: ->
		@html require("views/fmdepartment")(@item)
	
	change: (params) =>
		try
			$.when(@department).done =>
				if Department.exists params.id
					department = Department.find params.id
				else
					department = new Department
				@item = 
					department:department 
				@render()
		catch err
			@log "file: sysadmin.main.employee.option.departmentedit.coffee\nclass: DepartmentEdit\nerror: #{err.message}"

	getItem:->
		@item

module.exports = DepartmentAddTexts