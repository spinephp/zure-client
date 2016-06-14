Spine = require('spine')
require('spine/lib/ajax')

# 创收据模型
class TheOrderState extends Spine.Model
	@configure 'TheOrderState', 'id','orderid','time','stateid'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=OrdersState'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"orderid",value:$.fn.getUrlParam("orderid"),operator:"eq"}]
		token = $.fn.cookie 'PHPSESSID'
		params or= 
			data:{ cond:condition,filter: fields, token:token } 
			processData: true
		super(params)

module.exports = TheOrderState
