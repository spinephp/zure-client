Spine   = require('spine')
Default = require('models/default')
Orderstate = require('models/orderstate')
Thisstate = require('models/theorderstate')
$       = Spine.$

class Process extends Spine.Controller
	className: 'process'
    
	elements: 
		'dl dt span': 'editEl'
  
	constructor: ->
		super

		@orderid = $.fn.getUrlParam "orderid"

		@active @change
		
		@default = $.Deferred()
		@orderstate= $.Deferred()
		@thisstate = $.Deferred()
		Default.bind "refresh",=>@default.resolve()
		Orderstate.bind "refresh",=>@orderstate.resolve()
		Thisstate.bind "refresh",=>@thisstate.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
  
	render: =>
		@html require('views/showprocess') @item
    
	change: (params) =>
		try
			$.when(@orderstate,@thisstate,@default).done =>
				default1 = Default.first()
				state = Orderstate.all()
				thisstate = Thisstate.findByAttribute "orderid",parseInt @orderid
				@item = 
					default:default1
					state:state
					thisstate:Thisstate
				@render()
		catch err
			@log "file:ordertetail.product.coffee\nclass:Products\nerror: #{err.message}"
    
module.exports = Process