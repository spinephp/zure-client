Spine   = require('spine')
Qiye = require('models/qiye')
Navigation = require('models/navigation')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Good = require('models/good')
Cart = require('models/cart')
Goodclass = require('models/goodclass')
Order = require('models/order')

#Manager = require('spine/lib/manager')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Middles = require('controllers/main.middle')

#Spine.Model.host = "http://127.0.0.1/woo/"

class Main extends Spine.Controller
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
		@middle  = new Middles
		
		#Order.bind "ajaxError",(record,xhr,settings,error) ->
		#	console.log xhr.responseText
		Order.bind "refresh",=>
			ids = []
			i = 0
			for order in Order.all()
				for goods in order.products
					ids[i++]=goods.proid unless goods.proid in ids
			fields = Good.attributes
			condition = [{ field: 'id',value: ids,operator:'in' }]
			params = 
				data:{filter: fields, cond:condition,token: $.fn.cookie 'PHPSESSID' } 
				processData: true
			Good.fetch params


		Qiye.fetch()
		Navigation.fetch()
		Language.fetch()
		Default.fetch()
		Cart.fetch()
		Currency.fetch()
		Goodclass.fetch()
			
		@routes
			'/main': (params) -> 
				@headers.active params
				@middle.active params
				@footers.active params
	
		@append @headers,@middle,@footers
		@navigate '/main'
	
module.exports = Main