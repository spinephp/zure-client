Spine = require('spine')

# ������ҵģ��
class User extends Spine.Model
	@configure 'User', 'id',"name","state"

module.exports = User
