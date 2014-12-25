Spine = require('spine')
require('spine/lib/ajax')

# ���վ�ģ��
class OrderState extends Spine.Model
	@configure 'OrderState', 'id','names'

	@extend Spine.Model.Ajax

	@url: '? cmd=OrderState'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = OrderState
