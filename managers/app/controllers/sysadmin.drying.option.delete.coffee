Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$

Word    = require('controllers/sysadmin.drying.option.show')
Verify   = require('controllers/main.verifycode')

class DryingDeletes extends Spine.Controller
	tag:"form"
	className: 'dryingdeletes'
  
	constructor: ->
		@active @change
		super
		@word = new Word
		@verify    = new Verify

		option = $('<button>submit</button>').addClass('submitoption').button().click (e)=>
			e.stopPropagation()
			e.preventDefault()
			item = @word.getItem()
			$.fn.makeDeleteParam @el,Drymain,(status)=>
				rec.destroy(ajax:false) for rec in item.drydatas if status.destroyed

			Drymain.scope = ''
			item.drymains.destroy() if confirm("删除客户将删除与该客户相关联的所有数据，如账号，订单等等，请谨慎操作！\n确实要删除客户 #{item.custom.getName()} 吗?")
		@append @word, @verify,option
		
	change: (params) =>
		@word.active params
		@verify.active params

module.exports = DryingDeletes