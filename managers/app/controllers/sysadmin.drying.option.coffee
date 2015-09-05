Spine   = require('spine')

$       = Spine.$

ShowDryings = require('controllers/sysadmin.drying.option.show')

class DryingOption extends Spine.Stack
	className: 'dryingoption stack'
	
	controllers:
		dryingshow: ShowDryings
	
module.exports = DryingOption