Spine = require('spine')

# ������ҵģ��
class User extends Spine.Model
	@configure 'User', 'id',"name","nick","picture"

	@extend Spine.Model.Local

module.exports = User
