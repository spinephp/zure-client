Spine	= require('spine')
Goodclass = require('models/goodclass')

$		= Spine.$

Word    = require('controllers/sysadmin.good.option.classshow')
Verify   = require('controllers/main.verifycode')

class GoodclassDeletes extends Spine.Controller
	tag:"form"
	className: 'goodclassdeletes'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.stopPropagation()
			e.preventDefault()
			item = @word.getItem()
			$.fn.makeDeleteParam @el,Goodclass
			item.goodclass.destroy() if confirm('确实要删除当前产品吗?')
			
		@append @word, @verify,option
		
	change: (params) =>
		@word.active params
		@verify.active params

module.exports = GoodclassDeletes