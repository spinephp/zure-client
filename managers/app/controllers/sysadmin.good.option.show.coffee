Spine	= require('spine')
Good = require('models/good')
Goodsharp = require('models/goodsharp')

$		= Spine.$

class GoodShows extends Spine.Controller
	className: 'goodshows'
  
	constructor: ->
		super
		@active @change
		Good.bind "refresh",=>@change
  
	render: ->
		@html require("views/good")(@item)
		$("body >header h2").text "经营管理->产品管理->产品信息"
	
	change: (params) =>
		try
			if Good.exists params.id
				goods = Good.find params.id
				@item = 
					good:goods
					sharp:Goodsharp.find parseInt goods.sharp
				@render()
		catch err
			@log "file: sysadmin.main.good.option.classshow.coffee\nclass: GoodclassShows\nerror: #{err.message}"

	getItem:->
		@item

module.exports = GoodShows