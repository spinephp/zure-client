Spine = require('spine')
require('spine/lib/ajax')

class Consignee extends Spine.Model
	@configure 'Consignee','id','name'
  
	@extend Spine.Model.Ajax
	@url:'index.php? cmd=Consignee'

module.exports = Consignee