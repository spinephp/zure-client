Spine = require('spine')

# 创建企业模型
class Cart extends Spine.Model
	@configure 'Cart', 'id',"proid","number","price","returnnow"

	@extend Spine.Model.Local
	@url:"? cmd=Product"
	
	# 向服务器查寻一条数据
	@getOrder:(data)->
		jQuery.ajax
			type: 'get'
			url: @url
			data: data
			async: true   #ajaxִ执行完毕后才执行后续指令
			success: (result) ->
				obj = JSON.parse(result)
				if typeof (obj) is "object"
					_orders = []
					for o in obj when o isnt null
						_orders[parseInt(o.id)] = { classid: o.classid, image: o.picture, size: o.size, price: o.price, returnnow: o.returnnow }
					sessionStorage.setItem("orders", JSON.stringify(_orders))

	aRecordEx:()->
		items = JSON.parse(sessionStorage.getItem("orders"))
		items[@proid]
		
	@sumn:()->
		0

module.exports = Cart
