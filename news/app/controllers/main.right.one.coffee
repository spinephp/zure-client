Spine	= require('spine')
News = require('models/news')
Default = require('models/default')

$		= Spine.$

class One extends Spine.Controller
	className: 'one'

	constructor: ->
		super
		@active @change
		
		@news = $.Deferred()
		@default = $.Deferred()
		News.bind "refresh",=>@news.resolve()
		Default.bind "refresh",=>@default.resolve()

		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
  
	render: ->
		@html require("views/one")(@item)
	
	change: (params) =>
		try
			$.when(@news,@default).done =>
				default1 = Default.first()
				@item = 
					news:News.find params.id
					default:default1
				@render()
		catch err
			@log "file: main.right.one.coffee\nclass: One\nerror: #{err.message}"

module.exports = One