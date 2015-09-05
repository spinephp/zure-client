Spine	= require('spine')
Goodclass = require('models/goodclass')

$		= Spine.$

class GoodclassShows extends Spine.Controller
	className: 'goodclassshows'
  
	constructor: ->
		super
		@active @change
		@goodclass = $.Deferred()
		Goodclass.bind "refresh",=>@goodclass.resolve()
  
	render: ->
		@html require("views/goodclass")(@item)
		$("body >header h2").text "经营管理->产品管理->产品类信息"
	
	change: (params) =>
		try
			$.when(@goodclass).done =>
				if Goodclass.exists params.id
					@item = 
						goodclass:Goodclass.find params.id
					@render()
		catch err
			@log "file: sysadmin.main.good.option.classshow.coffee\nclass: GoodclassShows\nerror: #{err.message}"

module.exports = GoodclassShows