Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$

class DryingDeletes extends Spine.Controller
	className: 'dryingdeletes'
  
	elements:
		'form':'formEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		@url = Drymain.url
		Drymain.bind "refresh",=>@drymain.resolve()
  
	render: ->
		@html require("views/drydelete")(@item)
		$("body >header h2").text "劳资管理->员工管理->删除员工"
	
	change: (params) =>
		try
			$.when( @drymain).done =>
				if Drymain.exists params.id
					drymain = Drymain.find params.id
					@item = 
						drymains:drymain
					@render()
		catch err
			@log "file: sysadmin.drying.option.delete.coffee\nclass: DryingDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		key = $(@formEl).serializeArray()
		Drymain.one "beforeDestroy", =>
			Drymain.url = "woo/"+Drymain.url if Drymain.url.indexOf("woo/") is -1
			Drymain.url += "&token="+ $.fn.cookie('PHPSESSID') unless Drymain.url.match /token/
			Drymain.url += "&#{field.name}=#{field.value}" for field in key when not Drymain.url.match "&#{field.name}="

		Drymain.one "ajaxSuccess", (status, xhr) => 
			Drymain.url = @url
			items = Drydatas.findByAttribute 'mainid',@item.drymains.id
			items.destroy ajax:false

		@item.drymains.destroy() if confirm("确实要删除员工 #{@item.employee.getName()} 吗?")

module.exports = DryingDeletes