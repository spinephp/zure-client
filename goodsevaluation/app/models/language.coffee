Spine = require('spine')
require('spine/lib/ajax')

# ������ҵģ��
class Language extends Spine.Model
	@configure 'Language', 'id',"name_en"

	@extend Spine.Model.Ajax

	@url: '? cmd=Language'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{filter: fields,token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Language
