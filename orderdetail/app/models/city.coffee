Spine = require('spine')
# ���վ�ģ��
class City extends Spine.Model
	@configure 'City', 'id', 'name'

	@extend Spine.Model.Local

	@url: '? cmd=City'

module.exports = City
