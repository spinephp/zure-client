Spine = require('spine')

# 创配送方式模型
class Carriageclass extends Spine.Model
	@configure 'Carriageclass', 'id', 'address','chargeid'

	@extend Spine.Model.Local

	@url: 'woo/index.php? cmd=CarriageClass'

module.exports = Carriageclass
