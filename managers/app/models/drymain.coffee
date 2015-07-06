Spine = require('spine')
require('spine/lib/ajax')

# ���վ�ģ��
class Drymain extends Spine.Model
	@configure 'Drymain', 'id','starttime','lineno','state'

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Drymain'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Drymain
