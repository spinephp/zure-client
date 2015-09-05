Spine	= require('spine')
Order = require('models/order')

$		= Spine.$
Infomations = require('controllers/sysadmin.progress.infomation')
Progressbars = require('controllers/sysadmin.progress.history')
Products = require('controllers/sysadmin.progress.product')

class ProgressOPtions extends Spine.Controller
	className: 'progressoptions'
  
	constructor: ->
		super
		@active @change
	
		@infomations    = new Infomations
		@progressbars    = new Progressbars
		@products      = new Products
	
		@append @infomations,@progressbars,@products

	change: (params) ->
		@infomations.active params
		@progressbars.active params
		@products.active params

module.exports = ProgressOPtions