Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')

$		= Spine.$

class CustomShows extends Spine.Controller
	className: 'customshows'
  
	constructor: ->
		super
		@active @change
		@custom = $.Deferred()
		@person = $.Deferred()
		Custom.bind "refresh",=>@custom.resolve()
		Person.bind "refresh",=>
			return for citem in Custom.all() when not Person.exists citem.userid
			@person.resolve()
  
	render: ->
		@html require("views/custom")(@item)
		$("body >header h2").text "经营管理->客户管理->客户信息"
	
	change: (params) =>
		try
			$.when(@custom,@person).done =>
				if Custom.exists params.id
					custom = Custom.find params.id
					@item = 
						custom:custom
						person:Person.find custom.userid
					@render()
		catch err
			@log "file: sysadmin.main.custom.option.show.coffee\nclass: CustomShows\nerror: #{err.message}"

module.exports = CustomShows