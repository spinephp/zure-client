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
			Drymain.fetch()
		
		Drymain.bind 'refresh',=>
			if Drymain.count()
				# 因干燥数据巨大，每次只从远程取一次干燥数据
				item = Drymain.first()
				condition = [{field:"mainid",value:item.id,operator:"eq"}]
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
			'/dryings/:id/delete': (params) -> 
				@active(params)
				@tree.active params
				@option.dryingdelete.active(params)
     
		divide = $('<div />').addClass('vdivide')
    
		@append @tree, divide, @option
    
		if Drymain.count()
			id = Drymain.first().id
		@navigate('/dryings',id,'show') 
    
module.exports = Dryings