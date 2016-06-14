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
Person = require('models/person')
My = require('models/my')

#Manager = require('spine/lib/manager')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Arts = require('controllers/main.resetpassword')

#Spine.Model.host = "http://127.0.0.1/woo/"

class main extends Spine.Controller
	className: 'mains'
  
	constructor: ->
		super

		$.fn.getUrlParam = (name) ->
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

		@headers = new Headers
		@arts = new Arts
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
		My.fetch()			
			
		@routes
			'/resetpwd': (params) -> 
				@headers.active params
				@arts.active(params)
				@footers.active(params)
	
		@append @headers,@arts,@footers

		@navigate "/resetpwd"

module.exports = main
