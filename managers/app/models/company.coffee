Spine = require('spine')
require('spine/lib/ajax')
Company = require('models/company')

# 创建企业模型
class Company extends Spine.Model
	@configure 'Company', 'id',"name"


	@extend Spine.Model.Ajax

	@url: '? cmd=Company'

module.exports = Company
