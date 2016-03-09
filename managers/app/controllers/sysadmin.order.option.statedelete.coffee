Spine	= require('spine')
Orderstate = require('models/orderstate')

$		= Spine.$

Word    = require('controllers/sysadmin.order.option.stateshow')
Verify   = require('controllers/main.verifycode')

class OrderstateDeletes extends Spine.Controller
	tag:"form"
	className: 'orderstatedeletes'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.stopPropagation()
			e.preventDefault()
			$.fn.makeDeleteParam @el,Orderstate
			Orderstate.scope = ''
			@word.getItem().orderstate.destroy() if confirm('确实要删除当前产品吗?')
		@append @word, @verify,option
		
	change: (params) =>
		@word.active params
		@verify.active params

module.exports = OrderstateDeletes