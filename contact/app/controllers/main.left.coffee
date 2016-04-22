Spine   = require('spine')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Qiye = require('models/qiye')
Person = require('models/person')
$       = Spine.$
addOrderDialog = require('controllers/addOrderDialog')

class Left extends Spine.Controller
	className: 'lefts'
  
	constructor: ->
		super
		@active @change
		
		@qiye = $.Deferred()
		@person = $.Deferred()
		@currency = $.Deferred()
		@language = $.Deferred()
		@default = $.Deferred()

		Qiye.bind "refresh",=>@personfetch()
		Currency.bind "refresh",=>@currency.resolve()
		Language.bind "refresh",=>@language.resolve()
		Default.bind "refresh",=>@default.resolve()

		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()
	 
	render: =>
		@html require('views/left')(@item)
	
	change: (params) =>
		try
			$.when(@qiye,@person,@currency,@language,@default).done =>
				default1 = Default.first()
				@item = 
					qiye:Qiye.first()
					person:Person
					defaults: default1
				@render()
		catch err
			console.log err.message

	personfetch:->
		@qiye.resolve()
		Person.one "refresh",=>@person.resolve()
		qiye = Qiye.first()
		ids = [qiye.techid,qiye.busid]
		Person.append ids if ids.length > 0

module.exports = Left
