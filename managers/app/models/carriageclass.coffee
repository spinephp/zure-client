Spine = require('spine')

# �����ͷ�ʽģ��
class Carriageclass extends Spine.Model
	@configure 'Carriageclass', 'id', 'address','chargeid'

	@extend Spine.Model.Local

	@url: 'woo/index.php? cmd=CarriageClass'

module.exports = Carriageclass
