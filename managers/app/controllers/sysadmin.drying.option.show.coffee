Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$

class DryingShows extends Spine.Controller
	className: 'employeeshows'
  
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		@drydata = $.Deferred()
		Drymain.bind "refresh",=>@drymain.resolve()
		Drydata.bind "refresh",=>@drydata.resolve()
  
	render: ->
		@html require("views/dryshow")(@item)
		$("body >header h2").text "????->????->????"
	
	change: (params) =>
		try
			$.when(@drymain,@drydata).done =>
				if Drymain.exists params.id
					drymain = Drymain.find params.id
					@item = 
						drymains:drymain
						drydatas:Show
					@render()
		catch err
			@log "file: sysadmin.drying.option.show.coffee\nclass: DryingShows\nerror: #{err.message}"

module.exports = DryingShows