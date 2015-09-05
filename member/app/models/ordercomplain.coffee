Spine = require('spine')
Complain = require('models/complain')
require('spine/lib/ajax')

# 创收据模型
class OrderComplain extends Spine.Model
	@configure 'OrderComplain', 'id','orderid','content','type','time','status'

	@extend Spine.Model.Ajax

	@url: '? cmd=OrderComplain'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

	getTypeName:->
		Complain.find(@type).names[sessionStorage.language]

	getStatusName:->
		{"S":["待处理","Pending"],"D":["已受理","Accepted"],"C":["已关闭","Closed"]}[@status][sessionStorage.language]

module.exports = OrderComplain
