Spine = require('spine')

# 创建企业模型
class User extends Spine.Model
	@configure 'User', 'id',"name","state"

module.exports = User
