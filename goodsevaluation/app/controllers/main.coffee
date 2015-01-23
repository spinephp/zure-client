Spine   = require('spine')
Qiye = require('models/qiye')
Navigation = require('models/navigation')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Good = require('models/good')
Cart = require('models/cart')
Goodclass = require('models/goodclass')
Goodeval = require('models/goodeval')
Theeval = require('models/theeval')
Thefeel = require('models/thefeel')
Person = require('models/person')
User = require('models/user')

#Manager = require('spine/lib/manager')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Lefts = require('controllers/main.left')
Rights = require("controllers/main.right")

#Spine.Model.host = "http://127.0.0.1/woo/"

class goodsevaluation extends Spine.Controller
	className: 'goodsevaluations'
  
	constructor: ->
		super

		$.getUrlParam = (name) ->
			results = new RegExp('[\\?& ]' + name + '=([^&#]*)')
						.exec(decodeURI(window.location.href))
			return null if not results
			results[1] || 0
    
		$.fn.cookie = (c_name)->
			if document.cookie.length>0
				c_start=document.cookie.indexOf(c_name + "=")
				if c_start isnt -1
					c_start=c_start + c_name.length+1 
					c_end=document.cookie.indexOf(";",c_start)
					c_end=document.cookie.length if c_end is -1 
					return unescape(document.cookie.substring(c_start,c_end))
			return ""

		name = "/"
		id = $.getUrlParam 'eid'
		if id?
			name = '/review'

			Theeval.bind "refresh",=>
				@_addGoods Theeval.first()

			fields = Theeval.attributes
			condition = [{field:'id',value:id,operator:'eq'}]
			params = 
				data:{ filter: fields,cond:condition, token: $.fn.cookie 'PHPSESSID' } 
				processData: true
			Theeval.fetch params
		else
			id = $.getUrlParam('sid')
			name = '/single'

			Thefeel.bind "refresh",=>
				@_addGoods Thefeel.first()
			Thefeel.append [id] unless Thefeel.exists id
			

		@headers = new Headers
		@lefts = new Lefts
		@rights    = new Rights
		@footers   = new Footers
		
		#Order.bind "ajaxError",(record,xhr,settings,error) ->
		#	console.log xhr.responseText

		Qiye.fetch()
		Navigation.fetch()
		Language.fetch()
		Default.fetch()
		Cart.fetch()
		Currency.fetch()
		Goodclass.fetch()
		User.fetch()
			
		@routes
			'/review/:id': (params) -> 
				@headers.active params
				@lefts.active(params)
				@rights.eval.active(params)
				@footers.active(params)
			'/single/:id': (params) -> 
				@headers.active params
				@lefts.active(params)
				@rights.feel.active(params)
				@footers.active(params)
	
		@append @headers,@lefts,@rights,@footers
		@navigate name,id

	_addGoods:(reval)->
		fields = Good.attributes
		condition = [{field:'id',value:reval.proid,operator:'eq'}]
		params = 
			data:{ filter: fields,cond:condition, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		Good.fetch params

		fields = Goodeval.attributes
		condition = [{field:'proid',value:reval.proid,operator:'eq'}]
		params = 
			data:{ filter: fields,cond:condition, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		Goodeval.fetch params

		Person.append [reval.userid]

module.exports = goodsevaluation