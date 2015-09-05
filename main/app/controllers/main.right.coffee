Spine   = require('spine')
User = require('models/user')
Manager = require('spine/lib/manager')
$       = Spine.$

Introductions = require('controllers/main.right.introduction')
Goods = require('controllers/main.right.good')

#Spine.Model.host = "http://127.0.0.1/woo/"

class rights extends Spine.Controller
	className: 'rights'
  
	constructor: ->
		super
		@active @change
		
		@introductions = new Introductions
		@goods = new Goods
	
		@append @introductions,@goods
	
	change:(param)->
		@introductions.active param
		@goods.active param
		
module.exports = rights