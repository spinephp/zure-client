Spine = require('spine')
require('spine/lib/ajax')

# 创收据模型
class Complain extends Spine.Model
	@configure 'Complain', 'id','names'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Complain'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token:  $.fn.cookie 'PHPSESSID'} 
			processData: true
		super(params)

module.exports = Complain
