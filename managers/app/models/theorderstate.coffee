Spine = require('spine')
require('spine/lib/ajax')

# 创收据模型
class TheOrderState extends Spine.Model
	@configure 'TheOrderState', 'id','orderid','time','stateid'

	@extend Spine.Model.Ajax

	@url: '? cmd=OrdersState'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = TheOrderState
