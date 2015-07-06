Spine   = require('spine')
Manager = require('spine/lib/manager')
$       = Spine.$
Drymain = require('models/drymain')
Drydata = require('models/drydata')

Option    = require('controllers/sysadmin.drying.option')
Tree = require('controllers/sysadmin.drying.tree')

class Dryings extends Spine.Controller
	className: 'dryings'
  
	constructor: ->
		super
			
		@tree = new Tree
		@option    = new Option

		Spine.bind "userlogined",(user)->
			Drymain.one 'refresh',->
				Drydata.append (item.userid for  item in Employee.all() when not Person.exists item.userid)
			Drymain.fetch()

			
		@routes
			'/dryings/new': (params) -> 
				@active(params)
				@tree.active params
				@option.employeeadd.active(params)
			'/dryings/:id/show': (params) -> 
				@active(params)
				@tree.active params
				@option.dryingshow.active(params)
			'/dryings/:id/edit': (params) -> 
				@active(params)
				@tree.active params
				@option.employeeedit.active(params)
			'/dryings/:id/delete': (params) -> 
				@active(params)
				@tree.active params
				@option.employeedelete.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		@navigate('/dryings',1,'show')
    
module.exports = Dryings