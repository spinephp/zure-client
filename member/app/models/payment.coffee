Spine = require('spine')
require('spine/lib/ajax')

# 创支付方式模型
class Payment extends Spine.Model
	@configure 'Payment', 'id', 'name'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Payment'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Payment