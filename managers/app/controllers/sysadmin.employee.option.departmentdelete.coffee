Spine	= require('spine')
Department = require('models/department')

$		= Spine.$

Word    = require('controllers/sysadmin.employee.option.departmentshow')
Verify   = require('controllers/main.verifycode')

class DepartmentDeletes extends Spine.Controller
	tag:"form"
	className: 'departmentdeletes'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.stopPropagation()
			e.preventDefault()
			item = @word.getItem()
			$.fn.makeDeleteParam @el,Department
			item.department.destroy() if confirm("确实要删除部门 [#{item.department.name}] 吗?")
		@append @word, @verify,option
		
	change: (params) =>
		@word.active params
		@verify.active params

module.exports = DepartmentDeletes