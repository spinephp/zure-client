Spine = require('spine')
OrderPerson = require('models/orderperson')
Orderstate = require('models/orderstate')
Consignee = require('models/consignee')
require('spine/lib/ajax')

# 创订单模型
class Order extends Spine.Model
	@configure 'Order', 'id','code','userid','products','shipdate','consigneeid','paymentid','transportid','billtypeid','billid','billcontentid','downpayment','guarantee','guaranteeperiod','carriagecharge','returnnow','stateid','contract','time','note'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Order'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"id",value:"0",operator:"gt"}]
		goodparams = ['id','orderid','proid','number','price','returnnow','modlcharge',"moldingnumber","drynumber","firingnumber","packagenumber","evalid","feelid"]
		params or= 
			data:{ cond:condition,filter: fields, params:{products:goodparams}, token: sessionStorage.token } 
			processData: true
		super(params)

	customCompanyId:->
		item = OrderPerson.find @userid
		item.companyid

	customName:->
		item = OrderPerson.find @userid
		item.name

	companyName:->
		item = OrderPerson.find @userid
		item.companyName()
		
	is_export:->
		item = Consignee.find @consigneeid
		item.country is 48
		
	sumNumber:->
		sum = 0
		sum += parseInt(rec.number) for rec in @products
		sum

	sumPrice:->
		sum = 0
		sum += parseFloat(rec.price)*parseInt(rec.number) for rec in @products
		sum

	sumReturnnow:->
		sum = 0
		sum += parseFloat(rec.returnnow)*parseInt(rec.number) for rec in @products
		sum

	sumModlcharge:->
		sum = 0
		sum += parseFloat(rec.modlcharge) for rec in @products
		sum

	total:->
		@sumPrice()+parseFloat(@carriagecharge)+@sumModlcharge()-@sumReturnnow()

	stateName:->
		item = Orderstate.find @stateid
		item.name

module.exports = Order
