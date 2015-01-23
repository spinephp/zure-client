Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Theeval extends Spine.Model
	@configure 'Theeval', 'id',"proid","userid","label","useideas","star","date","useful","status","buydate"

	@extend Spine.Model.Ajax

	@url: '? cmd=ProductEval'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Theeval
