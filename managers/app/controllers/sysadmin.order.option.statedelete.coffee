Spine	= require('spine')
Orderstate = require('models/orderstate')

$		= Spine.$

class OrderstateDeletes extends Spine.Controller
	className: 'orderstatedeletes'
  
	elements:
		'form':'formEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@orderstate = $.Deferred()
		@url = Orderstate.url
		Orderstate.bind "refresh",=>@orderstate.resolve()
  
	render: ->
		@html require("views/orderstatedelete")(@item)
		$("body >header h2").text "经营管理->产品管理->删除产品"
	
	change: (params) =>
		try
			$.when( @orderstate).done =>
				if Orderstate.exists params.id
					@item = 
						orderstate:Orderstate.find params.id
					@render()
		catch err
			@log "file: sysadmin.main.order.option.statedelete.coffee\nclass: OrderstateDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		$.fn.makeDeleteParam @formEl,Orderstate
		@item.orderstate.destroy() if confirm('确实要删除当前产品吗?')

module.exports = OrderstateDeletes