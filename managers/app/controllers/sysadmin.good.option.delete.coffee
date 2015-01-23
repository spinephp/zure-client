Spine	= require('spine')
Good = require('models/good')

$		= Spine.$

class GoodDeletes extends Spine.Controller
	className: 'gooddeletes'
  
	elements:
		'form':'formEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@good = $.Deferred()
		@url = Good.url
		Good.bind "refresh",=>@good.resolve()
  
	render: ->
		@html require("views/gooddelete")(@item)
		$("body >header h2").text "经营管理->产品管理->删除产品"
	
	change: (params) =>
		try
			$.when( @good).done =>
				if Good.exists params.id
					@item = 
						good:Good.find params.id
					@render()
		catch err
			@log "file: sysadmin.main.good.option.classdelete.coffee\nclass: GoodDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		key = $(@formEl).serializeArray()
		Good.one "beforeDestroy", =>
			Good.url = "woo/"+Good.url if Good.url.indexOf("woo/") is -1
			Good.url += "&token="+ $.fn.cookie('PHPSESSID') unless Good.url.match /token/
			Good.url += "&#{field.name}=#{field.value}" for field in key when not Good.url.match "&#{field.name}="

		Good.one "ajaxSuccess", (status, xhr) => 
			Good.url = @url

		@item.good.destroy() if confirm('确实要删除当前产品吗?')

module.exports = GoodDeletes