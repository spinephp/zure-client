Spine	= require('spine')
Good = require('models/good')
Goodsharp = require('models/goodsharp')

$		= Spine.$

Word    = require('controllers/sysadmin.good.option.show')
Verify   = require('controllers/main.verifycode')

class GoodDeletes extends Spine.Controller
	tag:"form"
	className: 'gooddeletes'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.stopPropagation()
			e.preventDefault()
			item = @word.getItem()
			$.fn.makeDeleteParam @el,Good
			item.good.destroy() if confirm('确实要删除当前产品吗?')
			
		@append @word, @verify,option
		
	change: (params) =>
		@word.active params
		@verify.active params

module.exports = GoodDeletes