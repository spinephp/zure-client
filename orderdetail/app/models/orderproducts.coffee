Spine = require('spine')
require('spine/lib/ajax')
Order   = require('models/order')

# 创增值税发票模型
class OrderProducts extends Spine.Model
	@configure 'OrderProducts', 'id',  'longnames', 'size','picture','unit'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Product'

	@fetch: (params) ->
		fields = @attributes
		item = Order.find $.fn.getUrlParam "orderid"
		values = (rec.proid for rec in item.products)
		condition = [{field:"id",value:values,operator:"in"}]
		token = $.fn.cookie 'PHPSESSID'
		params or= 
			data:{ cond:condition,filter: fields, token:token } 
			processData: true
		super(params)

	formatId:->
		str = ""+@id
		str = "0"+str while str.length<8
		str

	@sumNumber:->
		sum = 0
		goods = Order.find $.fn.getUrlParam "orderid"
		sum += parseInt rec.number for rec in goods.products
		sum

	@sumPrice:->
		sum = 0
		goods = Order.find $.fn.getUrlParam "orderid"
		sum += rec.price*rec.number for rec in goods.products
		sum

	@sumReturnnow:->
		item = Order.find $.fn.getUrlParam "orderid"
		sum = 0
		sum += rec.returnnow*rec.number for rec in item.products
		sum

	@sumModlcharge:->
		item = Order.find $.fn.getUrlParam "orderid"
		sum = 0
		sum += rec.modlcharge for rec in item.products
		sum

	@total:->
		goods = Order.find $.fn.getUrlParam "orderid"
		@sumPrice()-@sumReturnnow()+@sumModlcharge()+goods.carriagecharge

module.exports = OrderProducts
