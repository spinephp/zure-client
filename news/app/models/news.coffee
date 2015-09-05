Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
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
