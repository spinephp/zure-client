Spine	= require('spine')
Goodclass = require('models/goodclass')
Good = require('models/good')
Goodsharp = require('models/goodsharp')

$		= Spine.$

class GoodAddTexts extends Spine.Controller
	className: 'textoption'
  
	elements:
		"button":"buttonEl"
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
  
	constructor: ->
		super
		@active @change
		@good = $.Deferred()
		Good.bind "refresh",=>@good.resolve()
		@goodsharp = $.Deferred()
		Goodsharp.bind "refresh",=>@goodsharp.resolve()
		@goodclass = $.Deferred()
		Goodclass.bind "refresh",=>@goodclass.resolve()
		Good.bind "create",(item)=>
			@item.good.updateAttributes item,ajax: false
	render: ->
		@html require("views/fmgood")(@item)
	
	change: (params) =>
		try
			$.when( @good,@goodsharp,@goodclass).done =>
				good = null
				if params.id?
					if Good.exists params.id
						good = Good.find params.id
				else
					good = new Good
				if  good?
					@item = 
						good:good
						goodclasses:Goodclass.all()
						goodsharps:Goodsharp.all()
					@render()
					Spine.trigger "image:change",@item.good.picture
		catch err
			@log "file: sysadmin.main.good.option.add.text.coffee\nclass: GoodAddTexts\nerror: #{err.message}"

	getItem:->
		@item
		
module.exports = GoodAddTexts