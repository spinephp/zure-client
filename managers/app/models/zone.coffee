# ���վ�ģ��
class Zone extends Spine.Model
	@configure 'Zone', 'id','name'

	@extend Spine.Model.Local

	@url: '? cmd=District'

module.exports = Zone
