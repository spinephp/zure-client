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
		Drymain.bind 'refresh',=>
			if Drymain.count()
				@item = Drymain.first()
				condition = [{field:"mainid",value:@item.id,operator:"eq"}]
				token =  $.fn.cookie 'PHPSESSID'
				params = 
					data:{ filter: Drydata.attributes,cond:condition,token:token}
					processData: true

				Drydata.fetch params
			
		@routes
			'/dryings/:id/show': (params) -> 
				@active(params)
				@tree.active params
				@option.dryingshow.active(params)
			'/dryings/:id/edit': (params) -> 
				@active(params)
				@tree.active params
				@option.dryingedit.active(params)
			'/dryings/:id/delete': (params) -> 
				@active(params)
				@tree.active params
				@option.dryingdelete.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		@navigate('/dryings',@item.id,'show') if @item?
    
module.exports = Dryings