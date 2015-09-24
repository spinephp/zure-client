Spine	= require('spine')
Good = require('models/good')
Goodsharp = require('models/goodsharp')

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
		@goodsharp = $.Deferred()
		@url = Good.url
		Good.bind "refresh",=>@good.resolve()
		Goodsharp.bind "refresh",=>@goodsharp.resolve()
  
	render: ->
		@html require("views/gooddelete")(@item)
		$("body >header h2").text "经营管理->产品管理->删除产品"
	
	change: (params) =>
		try
			$.when( @good,@goodsharp).done =>
				if Good.exists params.id
					goods = Good.find params.id
					@item = 
						good:goods
						sharp:Goodsharp.find parseInt goods.sharp
					@render()
		catch err
			@log "file: sysadmin.main.good.option.classdelete.coffee\nclass: GoodDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		$.fn.makeDeleteParam @formEl,Good
		@item.good.destroy() if confirm('确实要删除当前产品吗?')

module.exports = GoodDeletes