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
		$.fn.makeDeleteParam @formEl,Goodclass
		@item.goodclass.destroy() if confirm('确实要删除当前产品吗?')

module.exports = GoodclassDeletes