Spine	= require('spine')
Goodclass = require('models/goodclass')

$		= Spine.$


class Goodclasses extends Spine.Controller
	className: 'goodclasses'
  
	elements:
		"button":"buttonEl"
		'tr .rowselected':'selectedEl'
		'tr':'trEl'
  
	events:
		'click button': 'option'
		'click tr': 'userSelect'
  
	constructor: ->
		super
		@active @change
		Goodclass.bind "ajaxError",(record,xhr,settings,error) ->
			console.log xhr.responseText
  
	render: ->
		@html require("views/goodclasses")(@item)
	
	change: (params) =>
		try
			$("body >header h2").text "经营管理->产品类管理"
			@goodclass = $.Deferred()

			Goodclass.bind "refresh",=>@goodclass.resolve()

			Goodclass.fetch()

			$.when( @goodclass).done( =>
				@item = 
					goodclasses:Goodclass.all()
				@render()
			)
		catch err
			@log "file: sysadmin.goodclass.coffee\nclass: Goodclasses\nerror: #{err.message}"

	userSelect:(e)->
		e.stopPropagation()
		$(@trEl).removeClass 'rowselected'
		$(e.target).parent().addClass 'rowselected'
	
	option: (e)->
		opt = $(e.target)
		row = $('.rowselected')
		id = parseInt row.eq(0).attr('data-id')
		switch $(@buttonEl).index opt
			when 0 # add employee
				@navigate('/sysadmins/addgoodclass')
			when 1 # edit employee
				@navigate('/sysadmins/goodclass', id, 'edit') if id > 0
			when 2 # delete employee
				try
					Goodclass.bind "beforeUpdate beforeDestroy", ->
						Goodclass.url = "woo/index.php"+Goodclass.url if Goodclass.url.indexOf("woo/index.php") is -1
						Goodclass.url += "&token="+ $.fn.cookie('PHPSESSID') unless Goodclass.url.match /token/
					oldUrl = Goodclass.url
					item = Goodclass.find(id)
					#item.bind "destory",->
						#Person.find(@userid).destroy()
					item.destroy() if confirm('确实要删除产品类 '+Goodclass.find(id).name+' 吗?')
					@item = 
						goodclasses:Goodclass.all()
					@render()
				catch err
					@log err
				finally
					Goodclass.url = oldUrl
				@navigate('/sysadmins/goodclass')

module.exports = Goodclasses