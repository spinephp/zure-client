Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Company extends Spine.Model
	@configure 'Company', 'id',"name"


	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Company'

module.exports = Company
