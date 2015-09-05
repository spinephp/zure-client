Spine = require('spine')
require('spine/lib/ajax')

# ��֧����ʽģ��
class Payment extends Spine.Model
	@configure 'Payment', 'id', 'name'

	@extend Spine.Model.Ajax

	@url: '? cmd=Payment'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Payment