Spine   = require('spine')
$		= Spine.$

GoodEvals = require('controllers/main.right.eval')
GoodFeels = require('controllers/main.right.feel')

class Rights extends Spine.Stack
	className: 'rights stack'
	
	controllers:
		eval: GoodEvals
		feel: GoodFeels
	
module.exports = Rights