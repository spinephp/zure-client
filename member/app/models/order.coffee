###
 模块      id code products shipdate consigneeid paymentid transportid billtypeid billid billcontentid carriagecharge stateid time note
 yunrui     Y          Y                                                                                                 Y
 orders     Y          Y                  Y                                                                              Y      Y
 complain   Y                                                                                                                   Y
 account    Y                                                                                                            Y      Y
 spending   Y          Y                                                                                                 Y      Y
 appraise   Y          Y                                                                                                 Y      Y

 products table
 模块      id orderid proid number price returnnow modlcharge moldingnumber drynumber firingnumber packagenumber evalid feelid
 yunrui     Y                                                                                                      Y      Y
 orders     Y           Y     Y      Y       Y
 complain   Y           Y
 spending   Y                 Y      Y       Y
 appraise   Y           Y                                                                                          Y      Y
###

Spine = require('spine')
require('spine/lib/ajax')
Consignee = require('models/consignee')
Orderstate = require('models/orderstate')

# 创收据模型
class Order extends Spine.Model
	@configure 'Order', 'id','code','products','shipdate','consigneeid','paymentid','transportid','billtypeid','billid','billcontentid','carriagecharge','stateid','time','note'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Order'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?userid",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, params:{products:['id','proid','number','price','returnnow','evalid','feelid']},token: $.fn.cookie 'PHPSESSID'} 
			processData: true
		super(params)

	@cost:(date1,date2)->
		m = 0
		m += rec.cost() for rec in @all() when date1 < @_dateToInt(rec.time) < date2 and rec.stateid is 13
		m

	@_dateToInt:(_time)->
		_date = _time[0..9].split '-'
		new Date _date[0],_date[1],_date[2]

	@costYear:->
		now = new Date()
		ago = new Date now.getYear()-1,now.getMonth(),now.getDate()
		@cost ago,now

	# 取订单在指定状态(多个)的待处理数
	@stateWaiting:(states)->
		n = 0
		n++ for item in @all() when item.stateid in states
		n

	# 取待处理订单数
	@pending:->
		@stateWaiting [2,3,9,11,12]

	# 取待付款订单数
	@waitPay:->
		@stateWaiting [3,9,12]

	# 取待付款订单数
	@waitReceive:->
		@stateWaiting [11]

	# 取待付款订单数
	@waitPickup:->
		@stateWaiting [11]

	@waitEval:->
		n = 0
		for item in @all() when item.stateid is 13
			n++ for rec in item.products when rec.evalid is 0
		n

	@waitFeel:->
		n = 0
		for item in @all() when item.stateid is 13
			n++ for rec in item.products when rec.feelid is 0
		n

	encodeId:->
		str = @id.toString()
		str = '0'+str while str.length<8
		str

	cost:->
		m = 0
		m += rec.number*(rec.price-rec.returnnow) for rec in @products
		m

	consigneeName:->
		Consignee.find(@consigneeid).name

	stateNames:->
		Orderstate.find(@stateid).names

module.exports = Order
