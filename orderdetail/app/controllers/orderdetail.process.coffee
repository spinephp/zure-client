Spine   = require('spine')
Orderstate = require('models/orderstate')
Thisstate = require('models/theorderstate')
$       = Spine.$

class Process extends Spine.Controller
	className: 'process'
    
	elements: 
		'dl dt span': 'editEl'
  
	constructor: ->
		super

		@orderid = $.getUrlParam "orderid"

		@active @change
		Thisstate.bind('refresh change', @render)
		Orderstate.bind('refresh change', @render)
  
	render: =>
		try
			if Thisstate.count() and Orderstate.count()
				state = Orderstate.all()
				thisstate = Thisstate.findByAttribute "orderid",@orderid
				@html require('views/showprocess')({thisstate:thisstate,state:state})
		catch err
			console.log err.message
    
	change: (params) =>
		@render()
    
module.exports = Process