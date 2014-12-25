Spine = require('spine')
require('spine/lib/ajax')

# ������ҵģ��
class Link extends Spine.Model
	@configure 'Link', 'id',"names",'url'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Link'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{filter: fields,token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Link
