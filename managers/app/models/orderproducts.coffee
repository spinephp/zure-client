Spine = require('spine')
require('spine/lib/ajax')
Order   = require('models/order')

# 创增值税发票模型
class OrderProducts extends Spine.Model
	@configure 'OrderProducts', 'id',  'longname', 'size','picture','unit'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Product'

	@fetch: (params) ->
		fields = @attributes
		values = []
		i = 0
		for order in Order.all()
			for item in order.products
				values[i++] = item.proid unless item.proid in values
		condition = [{field:"id",value:values,operator:"in"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

	formatId:->
		str = ""+@id
		str = "0"+str while str.length<8
		str

	price:->
		rec.price for rec in Order.first().products when rec.proid is @id 

	returnnow:->
		rec.returnnow for rec in Order.first().products when rec.proid is @id 

	modlcharge:->
		rec.modlcharge for rec in Order.first().products when rec.proid is @id 

	number:->
		sum = rec.number for rec in Order.first().products when rec.proid is @id 

	sumNumber:->
		sum = 0
		sum += parseInt rec.number for rec in Order.first().products
		sum

	sumPrice:->
		sum = 0
		sum += rec.price*rec.number for rec in Order.first().products
		sum

	sumReturnnow:->
		item = Order.first()
		sum = item.returnnow
		sum += rec.returnnow*rec.number for rec in item.products
		sum

	sumModlcharge:->
		item = Order.first()
		sum = item.returnnow
		sum += rec.modlcharge for rec in item.products
		sum

	total:->
		@sumPrice()+Order.first().carriagecharge

module.exports = OrderProducts
