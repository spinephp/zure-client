Spine	= require('spine')
News = require('models/news')
Default = require('models/default')

$		= Spine.$

class All extends Spine.Controller
	className: 'all'

	constructor: ->
		super
		@active @change
		@token = $.fn.cookie('PHPSESSID')
		
		@news = $.Deferred()
		@default = $.Deferred()
		News.bind "refresh",=>@news.resolve()
		Default.bind "refresh",=>@default.resolve()

		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
  
	render: ->
		@html require("views/all")(@item)
	
	change: (params) =>
		try
			$.when(@news,@default).done =>
				default1 = Default.first()
				@item = 
					news:News.all()
					default:default1
				@render()
		catch err
			@log "file: main.right.all.coffee\nclass: All\nerror: #{err.message}"
module.exports = All