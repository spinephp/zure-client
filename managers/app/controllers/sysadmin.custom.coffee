Spine   = require('spine')
Manager = require('spine/lib/manager')
$       = Spine.$
Custom = require('models/custom')
Person = require('models/person')
Country = require('models/country')

Option    = require('controllers/sysadmin.custom.option')
Tree = require('controllers/sysadmin.custom.tree')

class Customs extends Spine.Controller
	className: 'customs'
  
	constructor: ->
		super
			
		@tree = new Tree
		@option    = new Option

		Spine.bind "userlogined",(user)->
			Custom.one 'refresh',->
				Person.append (item.userid for  item in Custom.all() when not Person.exists item.userid)
			Custom.fetch()
			Country.fetch()

			
		@routes
			'/customtype/:id/show': (params) -> 
				@active(params)
				@tree.active params if params.id is '1'
				@option.customtypeshow.active(params)
			'/customs/new': (params) -> 
				@active(params)
				#@tree.active params
				@option.customadd.active(params)
			'/customs/:id/show': (params) -> 
				@active(params)
				#@tree.active params
				@option.customshow.active(params)
			'/customs/:id/edit': (params) -> 
				@active(params)
				#@tree.active params
				@option.customedit.active(params)
			'/customs/:id/delete': (params) -> 
				@active(params)
				#@tree.active params
				@option.customdelete.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		@navigate('/customtype',1,'show')
    
module.exports = Customs