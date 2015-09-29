Spine = require('spine')
require('spine/lib/ajax')

# ������ҵģ��
class Country extends Spine.Model
	@configure 'Country', 'id',"names","code3"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Country'
	@scope:"woo/"
	
	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Country
