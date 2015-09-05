Spine = require('spine')
require('spine/lib/ajax')
# 创收据模型
class Country extends Spine.Model
	@configure 'Country', 'id', 'code3','name'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Country'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Country
