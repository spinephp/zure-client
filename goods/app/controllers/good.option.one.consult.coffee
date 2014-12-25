Spine	= require('spine')
Qiye = require('models/qiye')
Good = require('models/good')
Person = require('models/person')
Grade = require('models/grade')
Goodconsult = require('models/goodconsult')
Custom = require('models/custom')
Customgrade = require('models/customgrade')
Default = require('models/default')

$		= Spine.$

class Goodconsults extends Spine.Controller
	className: 'goodconsults'
  
	elements:
		'div.tabsbox-eval':'tabsEl'

	constructor: ->
		super
		@active @change
		
		@qiye = $.Deferred()
		@good = $.Deferred()
		@person = $.Deferred()
		@grade = $.Deferred()
		@customgrade = $.Deferred()
		@default = $.Deferred()

		Qiye.bind "refresh",=>@qiye.resolve()
		Good.bind "refresh",=>@good.resolve()
		Person.bind "refresh",=>@person.resolve()
		Grade.bind "refresh",=>@grade.resolve()
		Customgrade.bind "refresh",=>@customgrade.resolve()
		Default.bind "refresh",=>@default.resolve()
		Goodconsult.bind "refresh",=>
			ids = []
			i = 0
			ids[i++] = rec.userid for rec in Goodconsult.all() when rec.userid not in ids and not Person.exists rec.userid
			Person.append ids if ids.length > 0

			ids = []
			i = 0
			ids[i++] = rec.userid for rec in Goodconsult.all() when rec.userid not in ids and Customgrade.findByAttribute('userid',rec.userid) is null
			Customgrade.append ids if ids.length > 0
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
  
		Goodconsult.fetch()

	render: ->
		$(@el).tabs('destroy') if $(@el).hasClass 'ui-tabs'
		@html require("views/goodconsult")(@item)
		$(@el).tabs()
	
	change: (params) =>
		try
			$.when(@qiye,@good,@person,@default,@grade,@customgrade).done =>
				if Good.exists params.id
					good = Good.find params.id
					default1 = Default.first()
					@item = 
						qiye:Qiye.first()
						good:good
						consults:Goodconsult.findAllByAttribute 'proid',parseInt params.id
						default:default1
					@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Goodconsults\nerror: #{err.message}"

module.exports = Goodconsults