Spine   = require('spine')
$		= Spine.$

One = require('controllers/main.right.one')
All = require('controllers/main.right.all')

class Rights extends Spine.Stack
	className: 'rights stack'
	
	controllers:
		anews: One
		all: All
	
module.exports = Rights