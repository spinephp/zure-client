Spine   = require('spine')
Qiye = require('models/qiye')
Navigation = require('models/navigation')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Good = require('models/good')
Cart = require('models/cart')
Goodclass = require('models/goodclass')
User = require('models/user')
News = require('models/news')

#Manager = require('spine/lib/manager')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Lefts = require('controllers/main.left')
Rights = require("controllers/main.right")

#Spine.Model.host = "http://127.0.0.1/woo/"

class main extends Spine.Controller
	className: 'mains'
  
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

		id = $.getUrlParam 'id'
		name = '/news'
			

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
		News.fetch()
			
		@routes
			'/news': (params) -> 
				@headers.active params
				@lefts.active(params)
				@rights.all.active(params)
				@footers.active(params)
			'/news/:id': (params) -> 
				@headers.active params
				@lefts.active(params)
				@rights.anews.active(params)
				@footers.active(params)
	
		@append @headers,@lefts,@rights,@footers
		if id?
			@navigate name,id
		else
			@navigate name

module.exports = main