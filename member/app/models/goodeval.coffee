Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Goodeval extends Spine.Model
	@configure 'Goodeval', 'id',"proid","userid","label","useideas","star","date","useful","status"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=ProductEval'
	@scope: 'woo/'

	@fetch: (params) ->
		params or= 
			data:{ filter: @attributes, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Goodeval
