Spine = require('spine')
require('spine/lib/ajax')

# ���վ�ģ��
class OrderState extends Spine.Model
	@configure 'OrderState', 'id','names'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=OrderState'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID'} 
			processData: true
		super(params)

module.exports = OrderState
