Spine = require('spine')
require('spine/lib/ajax')

# ������ҵģ��
class Navigation extends Spine.Model
	@configure 'Navigation', 'id',"names","command"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Navigation'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:filter: fields,token: $.fn.cookie 'PHPSESSID' 
			processData: true
		super(params)

module.exports = Navigation
