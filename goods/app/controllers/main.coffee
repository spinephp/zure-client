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

#Manager = require('spine/lib/manager')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Option    = require('controllers/good.option')
Tree = require('controllers/good.tree')

#Spine.Model.host = "http://127.0.0.1/woo/"

class main extends Spine.Controller
	className: 'main'
  
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
	
		@headers = new Headers
		@tree = new Tree
		@option    = new Option
		@footers   = new Footers
		
		#Order.bind "ajaxError",(record,xhr,settings,error) ->
		#	console.log xhr.responseText

		Qiye.fetch()
		Navigation.fetch()
		Language.fetch()
		Default.fetch()
		Cart.fetch()
		Currency.fetch()
		Good.fetch()
		Goodclass.fetch()
		User.fetch()
			
		@routes
			'/good/:id/class': (params) -> 
				@headers.active params
				@tree.active(params)
				@option.class.active(params)
				@footers.active(params)
			'/good/:id': (params) -> 
				@headers.active params
				@tree.active(params)
				@option.agood.active(params)
				@footers.active(params)
		
		divide = $('<div />').addClass('vdivide')
	
		@append @headers,@tree, @option,@footers

		id = $.getUrlParam 'gid'
		if id?
			@navigate '/good',id
		else
			id = $.getUrlParam('cid') or 1
			@navigate '/good',id,'class'

	
module.exports = main