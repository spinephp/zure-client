Spine = require('spine')
require('spine/lib/ajax')

# 创收据模型
class Order extends Spine.Model
	@configure 'Order', 'id','code','products','shipdate','consigneeid','paymentid','transportid','billtypeid','billid','billcontentid','carriagecharge','stateid','note'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Order'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?userid",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, params:{products:['id','proid','number','price','returnnow','evalid','feelid']}, token: sessionStorage.token } 
			processData: true
		super(params)

	# 取待处理订单数
	@Pending:->
		n = 0
		n++ for item in @all() when item.stateid in [2,3,9,11,12]
		n

module.exports = Order
