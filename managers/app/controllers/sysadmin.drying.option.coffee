Spine   = require('spine')

$       = Spine.$

ShowDryings = require('controllers/sysadmin.drying.option.show')
DeleteDryings  = require('controllers/sysadmin.drying.option.delete')

class DryingOption extends Spine.Stack
	className: 'dryingoption stack'
	
	controllers:
		dryingshow: ShowDryings
		dryingdelete: DeleteDryings 
	
module.exports = DryingOption