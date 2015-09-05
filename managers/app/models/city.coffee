Spine = require('spine')
# 创收据模型
class City extends Spine.Model
	@configure 'City', 'id', 'name'

	@extend Spine.Model.Local

	@url: 'index.php? cmd=City'

module.exports = City
