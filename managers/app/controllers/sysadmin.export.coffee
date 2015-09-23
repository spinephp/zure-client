Spine	= require('spine')

Qiye = require('models/qiye')
Order = require('models/order')
Product = require('models/orderproducts')
Company = require('models/company')
Person = require('models/person')
$		= Spine.$

class Exports extends Spine.Controller
	className: 'exports'

	elements:
		'form:first-child select':"addressEl"
  
	events:
		'click tbody tr':'orderClick'
  
	constructor: ->
		super
		@active @change
		@token = $.fn.cookie "PHPSESSID"

	render: ->
		@html require("views/export")(@item)
		
	change: (params) =>
		try
			@procuct = $.Deferred()
			@company = $.Deferred()
			@qiye = $.Deferred()

			Company.bind "ajaxError",(record,xhr,settings,error) ->
				console.log record+xhr.responseText+error
			Qiye.bind "ajaxError",(record,xhr,settings,error) ->
				console.log record+xhr.responseText+error
			Order.bind "ajaxError",(record,xhr,settings,error) ->
				console.log record+xhr.responseText+error

			Qiye.bind "refresh",=>@qiye.resolve()
			Company.bind "refresh",=>@company.resolve()
			Product.bind "refresh",=>@product.resolve()
			Person.bind "refresh",@orderfetch
			Order.bind "refresh",@afterfetch

			Person.fetch()
			Qiye.fetch()

			$.when( @qiye,@company,@product).done( =>
				@item = 
					orders:Order.all()
				@render()
			)
		catch err
			@log "file: sysadmin.export.coffee\nclass: Exports\nerror: #{err.message}"

	orderfetch:=>
		if Person.count() > 0
			fields = Order.attributes
			values = (item.id for item in Person.all())
			condition = [{field:"stateid",value:10,operator:"eq"},{field:"userid",value:values,operator:"in"}]
			params = 
				data:{ cond:condition,filter: fields, token: @token } 
				processData: true
			Order.fetch(params)
		else
			@afterfetch()

	afterfetch:=>
		if Order.count() >0
			fields = Company.attributes
			companyid = (item.customCompanyId() for item in Order.all())
			condition = [{field:"id",value:companyid,operator:"in"}]
			params =
				data:{ cond:condition,filter: fields, token: @token }
				processData: true
			Company.fetch(params)

			fields = Product.attributes
			i = 0
			ids = []
			for item in Order.all()
				ids[i++] = pro.proid for pro in item.products when pro.proid not in ids
			condition = [{field:"id",value:ids,operator:"in"}]
			params =
				data:
					cond:condition
					filter: fields
					token: @token
				processData: true
			Product.fetch params
		else
			@company.resolve()
			@product.resolve()

	orderClick:(e)->
		e.preventDefault()
		e.stopPropagation()
		@navigate('/members', @item.id, 'edit')

module.exports = Exports