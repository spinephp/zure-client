Spine   = require('spine')

$       = Spine.$

ShowDryings = require('controllers/sysadmin.drying.option.show')
EditDryings = require('controllers/sysadmin.drying.option.edit')
DeleteDryings = require('controllers/sysadmin.drying.option.delete')

class DryingOption extends Spine.Stack
	className: 'dryingoption stack'
	
	controllers:
		dryingshow: ShowDryings
		dryingedit: EditDryings
		dryingdelete: DeleteDryings
	
module.exports = DryingOption