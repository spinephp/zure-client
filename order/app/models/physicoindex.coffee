Spine = require('spine')
require('spine/lib/ajax')

# ������ҵģ��
class Physicoindex extends Spine.Model
	@configure 'Physicoindex', 'id',"names","unit","operator","values","environment"

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Physicoindex'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Physicoindex
