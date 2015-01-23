Spine   = require('spine')
Order = require('models/order')

$       = Spine.$

class ProgressInfomation extends Spine.Controller
	className: 'progresscurrent'
  
	constructor: ->
		super
		@active @change

		@order = $.Deferred()

		Order.bind "refresh",=>@order.resolve()
 
	render: =>
		@html require("views/progressinfomation")(@item)
	
	change: (params) =>
		try
			$.when( @order).done =>
				if Order.exists params.id
					order = Order.find params.id
					@item = 
						order:order
					@render()
		catch err
			@log "file: sysadmin.progress.infomation.coffee\nclass: ProgressInfomation\nerror: #{err.message}"

module.exports = ProgressInfomation