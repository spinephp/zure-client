Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Currency extends Spine.Model
	@configure 'Currency', 'id',"names","abbreviation","symbol","exchangerate"

	@extend Spine.Model.Ajax

	@url: '? cmd=Currency'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID'} 
			processData: true
		super(params)

module.exports = Currency
