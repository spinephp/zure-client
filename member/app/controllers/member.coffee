Spine   = require('spine')
Manager = require('spine/lib/manager')
Qiye = require('models/qiye')
Navigation = require('models/navigation')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Good = require('models/good')
Cart = require('models/cart')
Goodclass = require('models/goodclass')
User = require('models/user')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Main    = require('controllers/member.main')
Sidebar = require('controllers/member.sidebar')
loginDialog = require('controllers/loginDialog')

class Members extends Spine.Controller
	className: 'members'
  
	constructor: ->
		super
    
		$.fn.cookie = (c_name)->
			if document.cookie.length>0
				c_start=document.cookie.indexOf(c_name + "=")
				if c_start isnt -1
					c_start=c_start + c_name.length+1 
					c_end=document.cookie.indexOf(";",c_start)
					c_end=document.cookie.length if c_end is -1 
					return unescape(document.cookie.substring(c_start,c_end))
			return ""
			
		token = $.fn.cookie 'PHPSESSID'
			
		@urlroute = window.location.href #$.getUrlParam('cmd')
		n = @urlroute.indexOf("#")
		@urlroute = if n is -1 then	"/members" else @urlroute.substring n+1
		
		@default = $.Deferred()
		@user = $.Deferred()
		Default.bind "refresh",=>@default.resolve()
		User.bind "refresh",=>@user.resolve()

		$.when(@default,@user).done =>
			$.getJSON "? cmd=VerifyStatus&token=#{token}",(result)=>
				if result.status is false
					switch result.error
						when "Not logged!"
							loginDialog().open(default:Default.first(),user:User,sucess:->window.history.back(-1))
						when "Access Denied"
							alert result.error
							window.history.back(-1)
						when "Identity verify is invalid!"
							@navigate  if @urlroute is "/members/updatepassword" then "/members/password" else @urlroute

		@headers     = new Headers
		@footers     = new Footers
		@sidebar = new Sidebar
		@main    = new Main
		
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
			'/members/order': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.order.active(params)
				@footers.active(params)
			'/members/carefly': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.care.active(params)
				@footers.active(params)
			'/members/complain': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.complain.active(params)
				@footers.active(params)
			'/members/account': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.account.active(params)
				@footers.active(params)
			'/members/balance': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.balance.active(params)
				@footers.active(params)
			'/members/spending': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.spending.active(params)
				@footers.active(params)
			'/members/appraise': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.appraise.active(params)
				@footers.active(params)
			'/members/consult': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.consult.active(params)
				@footers.active(params)
			'/members/message': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.message.active(params)
				@footers.active(params)
			'/members/password': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.password.active(params)
				@footers.active(params)
			'/members/updatepassword': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.updatepassword.active(params)
				@footers.active(params)
			'/members': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.yunrui.active(params)
				@footers.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @headers,@sidebar, divide, @main,@footers
    
		@navigate @urlroute

module.exports = Members