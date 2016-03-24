Spine   = require('spine')

Goodconsult = require('models/goodconsult')
Goodclass = require('models/goodclass')
Orderproduct = require('models/orderproduct')
Default = require('models/default')
$       = Spine.$

class myConsult extends Spine.Controller
	className: 'myconsult'

	elements:
		".tabs":'tabsEl'
		"#home-menu-2 button": 'btnCare'
  
	events:
		'click .edit': 'edit'
  
	constructor: ->
		super
		@active @change
		@product = $.Deferred()
		@goodclass = $.Deferred()

		Orderproduct.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText

		Goodconsult.bind "refresh",@seekProduct
		Goodclass.bind "refresh",=> @goodclass.resolve()
		Orderproduct.bind "refresh",=> @product.resolve()
		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()


	render: ->
		@html require("views/consult")(@item)
	
	change: (params) =>
		try
			$.when(@product,@goodclass).done( =>
				defaults = Default.first()
				@item = 
					consults:Goodconsult.all()
					goodclass:Goodclass
					goods:Orderproduct
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.spending.coffee\nclass: myConsult\nerror: #{err.message}"
	
	seekProduct:=>
		if Goodconsult.count() > 0
			values = []
			i = 0
			values[i++] = pro.proid for pro in Goodconsult.all() when pro.proid not in values
			Orderproduct.append values if i > 0
		else
			@product.resolve()

	edit: ->
		@navigate('/members', @item.id, 'edit')

module.exports = myConsult