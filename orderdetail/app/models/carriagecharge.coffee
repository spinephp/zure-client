Spine = require('spine')

# 创配送方式模型
class Carriagecharge extends Spine.Model
	@configure 'Carriagecharge', 'id', 'grade1','grade2','grade3','grade4','grade5'

	@extend Spine.Model.Local

	@url: '? cmd=CarriageCharge'

module.exports = Carriagecharge
