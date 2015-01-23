Spine   = require('spine')
Manager = require('spine/lib/manager')
$       = Spine.$
Orderstate = require('models/orderstate')
Ordersstate = require('models/ordersstate')
OrderPerson = require('models/orderperson')
Order = require('models/order')

Option    = require('controllers/sysadmin.progress.option')
Tree = require('controllers/sysadmin.progress.tree')

class Progress extends Spine.Controller
	className: 'progress'
  
	constructor: ->
		super
			
		@tree = new Tree
		@option    = new Option

		Spine.bind "userlogined",(user)->
			Ordersstate.fetch()
			
		@routes
			'/progress': (params) -> 
				@active(params)
				@tree.active(params)
			'/progress/:id/show': (params) -> 
				@active(params)
				@tree.active(params)
				@option.active(params)
			'/progress/:id/edit': (params) -> 
				@active(params)
				@tree.active(params)
				@option.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		@navigate('/progress')
    
module.exports = Progress