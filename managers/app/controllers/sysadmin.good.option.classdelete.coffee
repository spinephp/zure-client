Spine	= require('spine')
Goodclass = require('models/goodclass')

$		= Spine.$

class GoodclassDeletes extends Spine.Controller
	className: 'goodclassdeletes'
  
	elements:
		'form':'formEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@goodclass = $.Deferred()
		@url = Goodclass.url
		Goodclass.bind "refresh",=>@goodclass.resolve()
  
	render: ->
		@html require("views/goodclassdelete")(@item)
		$("body >header h2").text "经营管理->产品管理->删除产品"
	
	change: (params) =>
		try
			$.when( @goodclass).done =>
				if Goodclass.exists params.id
					@item = 
						goodclass:Goodclass.find params.id
					@render()
		catch err
			@log "file: sysadmin.main.good.option.classdelete.coffee\nclass: GoodclassclassDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		key = $(@formEl).serializeArray()
		Goodclass.one "beforeDestroy", =>
			Goodclass.url = "woo/"+Goodclass.url if Goodclass.url.indexOf("woo/") is -1
			Goodclass.url += "&token="+ $.fn.cookie('PHPSESSID') unless Goodclass.url.match /token/
			Goodclass.url += "&#{field.name}=#{field.value}" for field in key when not Goodclass.url.match "&#{field.name}=" #存在问题是验证码不能更新

		Goodclass.one "ajaxSuccess", (status, xhr) => 
			Goodclass.url = @url
		@item.goodclass.destroy() if confirm('确实要删除当前产品吗?')

module.exports = GoodclassDeletes