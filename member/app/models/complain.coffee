Spine = require('spine')
require('spine/lib/ajax')

# ���վ�ģ��
class Complain extends Spine.Model
	@configure 'Complain', 'id','names'

	@extend Spine.Model.Ajax

	@url: '? cmd=Complain'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Complain
