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
			'/goodclass/new': (params) -> 
				@active params
				@tree.active params
				@option.classadd.active params
			'/goodclass/:id/show': (params) -> 
				@active params
				@tree.active params
				@option.classshow.active params
			'/goodclass/:id/edit': (params) -> 
				@active params
				@tree.active params
				@option.classedit.active params
			'/goodclass/:id/delete': (params) -> 
				@active params
				@tree.active params
				@option.classdelete.active params
			'/goods/new': (params) -> 
				@active params
				@tree.active params
				@option.goodadd.active params
			'/goods/:id/show': (params) -> 
				@active params
				@tree.active params
				@option.goodshow.active params
			'/goods/:id/edit': (params) -> 
				@active params
				@tree.active params
				@option.goodedit.active params
			'/goods/:id/delete': (params) -> 
				@active params
				@tree.active params
				@option.gooddelete.active params
    
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		@navigate('/goodclass',1,'show')
    
module.exports = Goods