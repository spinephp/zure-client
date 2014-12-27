Spine   = require('spine')

$       = Spine.$

GoodClasses = require('controllers/good.option.class')
Ones = require('controllers/good.option.one')

class GoodOption extends Spine.Stack
	className: 'goodoption stack'
	
	controllers:
		class: GoodClasses
		agood: Ones
	
module.exports = GoodOption