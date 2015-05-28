Spine = require('spine')
require('spine/lib/ajax')

# 创订单模型
class Order extends Spine.Model
	@configure 'Order', 'id','code','products','shipdate','consigneeid','paymentid','transportid','billtypeid','billid','billcontentid','downpayment','guarantee','guaranteeperiod','carriagecharge','returnnow','stateid','note'

	@extend Spine.Model.Ajax

	@url: '? cmd=Order'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"id",value:$.getUrlParam("orderid"),operator:"eq"}]
		param = {products:["id","orderid","proid","number","price","returnnow","modlcharge","moldingnumber","drynumber","firingnumber","packagenumber","evalid","feelid"]}
		params or= 
			data:{ cond:condition,filter: fields, params:param,token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Order
