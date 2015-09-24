Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Goodsharp extends Spine.Model
	@configure 'Goodsharp', 'id',"name"


	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=ProductSharp'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Goodsharp
