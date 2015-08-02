Spine   = require('spine')

$       = Spine.$

ShowDryings = require('controllers/sysadmin.drying.option.show')
EditDryings = require('controllers/sysadmin.drying.option.edit')

class DryingOption extends Spine.Stack
	className: 'dryingoption stack'
	
	controllers:
		dryingshow: ShowDryings
		dryingedit: EditDryings
	
module.exports = DryingOption