Spine	= require('spine')
Goodclass = require('models/goodclass')

$		= Spine.$

class GoodclassAddTexts extends Spine.Controller
	className: 'textoption'
  
	elements:
		"button":"buttonEl"
		'form':'formEl'
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
  
	constructor: ->
		super
		@active @change
		@goodclass = $.Deferred()
		Goodclass.bind "refresh",=>@goodclass.resolve()
		Goodclass.bind "create",(item)=>
			@item.goodclass.updateAttributes item,ajax: false

	render: ->
		@html require("views/fmgoodclass")(@item)
	
	change: (params) =>
		try
			$.when( @goodclass).done =>
				klass = null
				if params.id?
					if Goodclass.exists params.id
						klass = Goodclass.find params.id
				else
					klass = new Goodclass
				if  klass?
					@item = 
						goodclass:klass
						goodclasses:Goodclass.all()
					@render()
					Spine.trigger "image:change",@item.goodclass.picture
		catch err
			@log "file: sysadmin.main.good.option.classeadd.text.coffee\nclass: GoodclassAddTexts\nerror: #{err.message}"

	getItem:->
		@item
		
module.exports = GoodclassAddTexts