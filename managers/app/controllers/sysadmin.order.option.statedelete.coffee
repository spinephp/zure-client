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
		key = $(@formEl).serializeArray()
		Orderstate.one "beforeDestroy", =>
			Orderstate.url = "woo/"+Orderstate.url if Orderstate.url.indexOf("woo/") is -1
			Orderstate.url += "&token="+ $.fn.cookie('PHPSESSID') unless Orderstate.url.match /token/
			Orderstate.url += "&#{field.name}=#{field.value}" for field in key when not Orderstate.url.match "&#{field.name}=" #存在问题是验证码不能更新

		Orderstate.one "ajaxSuccess", (status, xhr) => 
			Orderstate.url = @url
		@item.orderstate.destroy() if confirm('确实要删除当前产品吗?')

module.exports = OrderstateDeletes