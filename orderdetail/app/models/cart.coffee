Spine = require('spine')

# ������ҵģ��
class Cart extends Spine.Model
	@configure 'Cart', 'id',"proid","number","price","returnnow"

	@extend Spine.Model.Local
	@url:"? cmd=Product"
	
	# ���������Ѱһ������
	@getCart:()->
		fields = @attributes
		condition = [{field:"userid",value:"?userid",operator:"eq"}]
		token = $.fn.cookie 'PHPSESSID'
		jQuery.getJSON '? cmd=Cart',{ cond:condition,filter: fields,token:token },(result) ->
			if result.length
				for o in result when not Cart.findByAttribute 'proid',o.porid
					new Cart proid:o.proid,number:o.number,price:o.price
	
	# ���������Ѱһ������
	@getOrder:(data)->
		jQuery.ajax
			type: 'get'
			url: @url
			data: data
			async: true   #ajaxִ����Ϻ��ִ�к���ָ��
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
module.exports = Cart
