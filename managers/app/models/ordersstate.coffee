Spine = require('spine')
State = require('models/ordersstate')
require('spine/lib/ajax')

# 创收据模型
class OrderState extends Spine.Model
	@configure 'OrderState', 'id','orderid','time','stateid'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=OrdersState'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

	finish:->
		Thisstate.findByAttribute "stateid",@id

	optionTime:->
		Thisstate.findByAttribute( "stateid",@id).time

	isLast:->
		@id is OrderState.last().id

module.exports = OrderState
