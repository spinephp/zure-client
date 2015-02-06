Spine = require('spine')
Thisstate = require('models/theorderstate')
require('spine/lib/ajax')

# 创收据模型
class OrderState extends Spine.Model
	@configure 'OrderState', 'id','name','actor','note','state'

	@extend Spine.Model.Ajax

	@url: '? cmd=OrderState'

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
