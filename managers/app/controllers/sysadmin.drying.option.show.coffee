Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$

class DryingShows extends Spine.Controller
	className: 'dryingshows'
  
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
					datas = Drydata.findByAttribute 'mainid',params.id
					unless datas?
						condition = [{field:"mainid",value:params.id,operator:"eq"}]
						token =  $.fn.cookie 'PHPSESSID'
						params = 
							data:{ filter: Drydata.attributes,cond:condition,token:token}
							processData: true

						Drydata.fetch params
					@item = 
						drymains:drymain
						drydatas:datas
					@render()
		catch err
			@log "file: sysadmin.drying.option.show.coffee\nclass: DryingShows\nerror: #{err.message}"

module.exports = DryingShows