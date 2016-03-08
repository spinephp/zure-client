Spine	= require('spine')
Employee = require('models/employee')

$		= Spine.$

Word    = require('controllers/sysadmin.employee.option.show')
Verify   = require('controllers/main.verifycode')

class EmployeeDeletes extends Spine.Controller
	tag:"form"
	className: 'employeedeletes'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.stopPropagation()
			e.preventDefault()
			item = @word.getItem()
			$.fn.makeDeleteParam @el,Employee,(status)=>
				item.person.destroy ajax:false

			Employee.scope = ''
			item.employee.destroy() if confirm("确实要删除员工 #{item.employee.getName()} 吗?")
			
		@append @word, @verify,option
		
	change: (params) =>
		@word.active params
		@verify.active params
		
module.exports = EmployeeDeletes