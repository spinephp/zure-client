Spine   = require('spine')

Goodconsult = require('models/goodconsult')
Orderproduct = require('models/orderproduct')
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

	render: ->
		@html require("views/consult")(@item)
	
	change: (params) =>
		try
			@product = $.Deferred()

			Orderproduct.bind "ajaxError",(record,xhr,settings,error) ->
				console.log record+xhr.responseText

			Goodconsult.bind "refresh",@seekProduct
			Orderproduct.bind "refresh",=> @product.resolve()

			Goodconsult.fetch()

			$.when(@product).done( =>
				@item = 
					consults:Goodconsult.all()
				@render()
			)
		catch err
			@log "file: member.main.spending.coffee\nclass: myConsult\nerror: #{err.message}"
	
	seekProduct:=>
		if Goodconsult.count() > 0
			fields = Orderproduct.attributes
			values = []
			i = 0
			values[i++] = pro.proid for pro in Goodconsult.all() when pro.proid not in values
			condition = [{field:"id",value:values,operator:"in"}]
			params = 
				data:{ cond:condition,filter: fields, token: sessionStorage.token } 
				processData: true
			Orderproduct.fetch(params)
		else
			@product.resolve()

	edit: ->
		@navigate('/members', @item.id, 'edit')

module.exports = myConsult