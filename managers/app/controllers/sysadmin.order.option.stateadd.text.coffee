Spine	= require('spine')
Orderstate = require('models/orderstate')

$		= Spine.$

class OrderstateAddTexts extends Spine.Controller
	className: 'textoption'
 
	elements:
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
 
	constructor: ->
		super
		@token = $.fn.cookie('PHPSESSID')
		@active @change
		@orderstate = $.Deferred()

		Orderstate.bind "refresh",=>@orderstate.resolve()
  
	render: ->
		@html require("views/fmorderstate")(@item)
	
	change: (params) =>
		try
			$.when( @custom,@person,@country).done =>
				if Orderstate.exists params.id
					orderstate = Orderstate.find params.id
				else
					orderstate = new Orderstate
				@item = 
					orderstate:orderstate
					orderstatees:Orderstate.all()
				@render()
		catch err
			@log "file: sysadmin.main.good.option.classedit.coffee\nclass: OrderstateEdit\nerror: #{err.message}"

	getItem:->
		@item

module.exports = OrderstateAddTexts