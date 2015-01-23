Spine = require('spine')
require('spine/lib/ajax')

# ����ֵ˰��Ʊģ��
class News extends Spine.Model
	@configure 'News', 'id','titles','contents','time'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=News'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:filter: fields,token: $.fn.cookie 'PHPSESSID' 
			processData: true
		super(params)

module.exports = News
