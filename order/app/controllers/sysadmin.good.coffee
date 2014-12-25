Spine   = require('spine')
Manager = require('spine/lib/manager')
$       = Spine.$
Goodclass = require('models/goodclass')
Good = require('models/good')

Option    = require('controllers/sysadmin.good.option')
Tree = require('controllers/sysadmin.good.tree')

class Goods extends Spine.Controller
	className: 'goods'
  
	constructor: ->
		super
			
		@tree = new Tree
		@option    = new Option

		Spine.bind "userlogined",(user)->
			Goodclass.fetch()
			Good.fetch()
			
		@routes
			'/goods/class/new': (params) -> 
				@active(params)
				@tree.active(params)
				@option.classadd.active(params)
			'/goods/class/:id/show': (params) -> 
				@active(params)
				@tree.active(params)
				@option.classshow.active(params)
			'/goods/class/:id/edit': (params) -> 
				@active(params)
				@tree.active(params)
				@option.classedit.active(params)
			'/goods/class/:id/delete': (params) -> 
				@active(params)
				@tree.active(params)
				@option.classdelete.active(params)
			'/goods/new': (params) -> 
				@active(params)
				@tree.active(params)
				@option.goodadd.active(params)
			'/goods/:id/show': (params) -> 
				@active(params)
				@tree.active(params)
				@option.goodshow.active(params)
			'/goods/:id/edit': (params) -> 
				@active(params)
				@tree.active(params)
				@option.goodedit.active(params)
			'/goods/:id/delete': (params) -> 
				@active(params)
				@tree.active(params)
				@option.gooddelete.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		@navigate('/goods/class',1,'show')
    
module.exports = Goods