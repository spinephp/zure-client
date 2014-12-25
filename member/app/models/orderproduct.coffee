Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Orderproduct extends Spine.Model
	@configure 'Orderproduct', 'id',"classid","size","picture"
	@extend Spine.Model.Ajax
	@url: '? cmd=Product'

module.exports = Orderproduct
