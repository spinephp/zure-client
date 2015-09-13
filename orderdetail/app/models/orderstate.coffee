Spine = require('spine')
Thisstate = require('models/theorderstate')
require('spine/lib/ajax')

# 创收据模型
class OrderState extends Spine.Model
	@configure 'OrderState', 'id','names','actor','notes','state'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=OrderState'

	@fetch: (params) ->
		fields = @attributes
		token = $.fn.cookie 'PHPSESSID'
		params or= 
			data:{ filter: fields, token:token } 
			processData: true
		super(params)

	finish:->
		Thisstate.findByAttribute "stateid",parseInt @id

	optionTime:->
		Thisstate.findByAttribute( "stateid",@id).time

	isLast:->
		parseInt(@id) is 13#OrderState.last().id

module.exports = OrderState
