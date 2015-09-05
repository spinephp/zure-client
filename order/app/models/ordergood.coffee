Spine = require('spine')
require('spine/lib/ajax')

# 创收据模型
class Ordergood extends Spine.Model
	@configure 'Ordergood', 'id','proid','evalid','feelid'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=OrderProduct'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Ordergood
