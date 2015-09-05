Spine = require('spine')

# 创收据模型
class Receipt extends Spine.Model
	@configure 'Receipt', 'id', 'name'

	@extend Spine.Model.Local

	@url: '? cmd=Receipt'

module.exports = Receipt
