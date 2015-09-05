# 创收据模型
class Zone extends Spine.Model
	@configure 'Zone', 'id','name'

	@extend Spine.Model.Local

	@url: 'index.php? cmd=District'

module.exports = Zone
