Spine = require('spine')

# ���վ�ģ��
class Receipt extends Spine.Model
	@configure 'Receipt', 'id', 'name'

	@extend Spine.Model.Local

	@url: '? cmd=Receipt'

module.exports = Receipt
