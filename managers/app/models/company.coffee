Spine = require('spine')
require('spine/lib/ajax')

# ������ҵģ��
class Company extends Spine.Model
	@configure 'Company', 'id',"name"


	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Company'

module.exports = Company
