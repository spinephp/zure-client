Spine = require('spine')
require('spine/lib/ajax')

# 创收据模型
class Department extends Spine.Model
	@configure 'Department', 'id','name'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Department'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Department
