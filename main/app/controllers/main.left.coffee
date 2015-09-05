Spine   = require('spine')
User = require('models/user')
Manager = require('spine/lib/manager')
$       = Spine.$

Customs = require('controllers/main.left.custom')
Newss = require('controllers/main.left.news')
Yunrui = require('controllers/main.left.yunrui')

#Spine.Model.host = "http://127.0.0.1/woo/"

class lefts extends Spine.Controller
	className: 'lefts'
  
	constructor: ->
		super

		@customs = new Customs
		@news = new Newss
		@yunrui = new Yunrui
		
		User.bind "refresh update change", =>
			if User.count() is 0
				@navigate '!/customs/login'
			else
				@navigate '!/customs/logout'
	
		@routes
			'!/customs/login': (params) -> 
				@active params
				@customs.login.active(params)
				@news.active(params)
				@yunrui.active(params)
			'!/customs/logout': (params) ->
				@active params
				@customs.logout.active(params)
				@news.active(params)
				@yunrui.active(params)
	
		@append @customs,@news,@yunrui

		$.getJSON "? cmd=GetLogId&token=#{$.fn.cookie 'PHPSESSID'}",(result)=>
			User.destroyAll() if result.id is -1 or not User.exists result.id
		if User.count() is 0
			@navigate '!/customs/login'
		else
			@navigate '!/customs/logout'
	
module.exports = lefts