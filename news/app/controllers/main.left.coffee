Spine   = require('spine')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
News = require('models/news')
$       = Spine.$
addOrderDialog = require('controllers/addOrderDialog')

class Left extends Spine.Controller
	className: 'lefts'
  
	constructor: ->
		super
		@active @change
		
		@news = $.Deferred()
		@currency = $.Deferred()
		@language = $.Deferred()
		@default = $.Deferred()

		News.bind "refresh",=>@news.resolve()
		Currency.bind "refresh",=>@currency.resolve()
		Language.bind "refresh",=>@language.resolve()
		Default.bind "refresh",=>@default.resolve()

		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()
	 
	render: =>
		@html require('views/lefts')(@item)
	
	change: (params) =>
		try
			$.when(@news,@currency,@language,@default).done =>
				default1 = Default.first()
				@item = 
					news:News.all()
					languages:Language.all()
					currencys:Currency.find default1.currencyid
					default: default1
				@render()
		catch err
			console.log err.message

module.exports = Left