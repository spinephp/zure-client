Spine   = require('spine')
Qiye = require('models/qiye')
Navigation = require('models/navigation')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
News = require('models/news')
Link = require('models/link')
Good = require('models/good')
Cart = require('models/cart')
Goodclass = require('models/goodclass')

#Manager = require('spine/lib/manager')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Lefts = require('controllers/main.left')
Rights = require("controllers/main.right")
Links = require("controllers/main.link")

#Spine.Model.host = "http://127.0.0.1/woo/"

class main extends Spine.Controller
	className: 'main'
  
	constructor: ->
		super

		$.getUrlParam = (name) ->
			results = new RegExp('[\\?& ]' + name + '=([^&#]*)')
						.exec(decodeURI(window.location.href))
			return 0 if not results
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
		@footers = new Footers
		@lefts   = new Lefts
		@rights  = new Rights
		@links   = new Links
		
		#Order.bind "ajaxError",(record,xhr,settings,error) ->
		#	console.log xhr.responseText

		Qiye.fetch()
		Navigation.fetch()
		Language.fetch()
		Default.fetch()
		Cart.fetch()
		Currency.fetch()
		Link.fetch()
		Good.fetch()
		Goodclass.fetch()
		News.fetch()
			
		@routes
			'/home': (params) -> 
				@headers.active params
				@lefts.active(params)
				@rights.active(params)
				@links.active(params)
				@footers.active(params)
		
		status = $("<div id='tabs'><ul><li><a href='.trail' >订单跟踪</a></li><li><a href='.pay' >付款信息</a></li></ul></div>")
		divide = $('<div class="infotitle">订单信息</div>')
	
		@append @headers,@lefts,@rights,@links,@footers
		@navigate '/home'

	
module.exports = main