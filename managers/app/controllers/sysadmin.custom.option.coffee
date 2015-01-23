Spine   = require('spine')

$       = Spine.$

ShowCustomTypes = require('controllers/sysadmin.custom.option.typeshow')

ShowCustoms = require('controllers/sysadmin.custom.option.show')
NewCustoms = require('controllers/sysadmin.custom.option.add')
EditCustoms = require('controllers/sysadmin.custom.option.edit')
DeleteCustoms = require('controllers/sysadmin.custom.option.delete')

class CustomOption extends Spine.Stack
	className: 'customoption stack'
	
	controllers:
		customtypeshow: ShowCustomTypes
		customshow: ShowCustoms
		customadd: NewCustoms
		customedit: EditCustoms
		customdelete: DeleteCustoms
	
module.exports = CustomOption