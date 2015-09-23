Spine	= require('spine')
Order = require('models/order')

$		= Spine.$

class OrderDeletes extends Spine.Controller
	className: 'orderdeletes'
  
	elements:
		'form':'formEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@order = $.Deferred()
		@url = Order.url
		Order.bind "refresh",=>@order.resolve()
  
	render: ->
		@html require("views/orderdelete")(@item)
		$("body >header h2").text "经营管理->产品管理->删除产品"
	
	change: (params) =>
		try
			$.when( @order).done =>
				if Order.exists params.id
					@item = 
						order:Order.find params.id
					@render()
		catch err
			@log "file: sysadmin.main.order.option.delete.coffee\nclass: OrderDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		$.fn.makeDeleteParam @formEl,Order
		@item.order.destroy() if confirm('确实要删除当前产品吗?')

module.exports = OrderDeletes