Spine = require('spine')
CC2PY = require('controllers/cc2py')

# 创建企业模型
class Default extends Spine.Model
	@configure 'Default', 'id',"languageid","currencyid"

	@extend Spine.Model.Local

	translates:(key)->
		if $.isArray key
			langid = parseInt(@languageid,10)
			return key[langid-1]
		@translate key
		
	translatem:(keys)->
		spac = [' ',''][Default.first().languageid-1]
		s = ''
		s += @translate(key)+spac for key in keys
		s
			
	translate:(key)->
		data = 
			# 页眉
			'YunRui':['云瑞']


			'My YunRui':['我的云瑞']

			'Hello, please':['您好，请']
			'Go my YunRui':['去我的云瑞首页']
			'The latest order status':['最新订单状态']
			'Check all order':['查看所有订单']
			'Pending orders':['待处理订单']
			'Consulting reply':['咨询回复']
			'Prices of goods':['降价商品']
			'My attention':['我的关注']


			'Go cart':['购物车']

			'The newest goods':['最新加入的商品']
			'Delete':['删除']
			'Orders containing':['订单包含']
			'kinds of products':['种产品']
			'A combined':['合计']
			'Order settlement':['订单结算']

			"AddFavorite":["加入收藏"]
			"SetHomepage":["设为首页"]
			'Home':["首页"]

			# 页脚
			'Address':["地址"]
			"ICP":["备案号"]
			"Copyright":["版权"]
			'All right reserved':["保留所有权利"]

			# 我的订单
			'My order':['我的订单']
			'Fill in the check order information':['填写核对订单信息']
			'Order submitted successfully':['成功提交订单']
			'Select all':['全选']
			'Goods':['商品']
			'Price':['单价']
			'Quantity':['数量']
			'Operation':['操作']
			'Delete':['删除']
			'Delete the selected items':['删除选中的商品']
			'items':['种商品']
			'A total of':['总计']
			'Cash back':['返现']
			'Excluding freight costs':['不含运费']
			'Order is empty, after login, will show the goods before you join':['订单为空，登录后，将显示您之前加入的商品']
			'To select the goods like the front page':['去首页挑选喜欢的商品']
			'Continue to choose goods':['继续选单']
			'To settle accounts':['去结算']
			'Delete the items from the order':['确定从订单中删除商品']
			'Delete all the selected items from the order':['确定从订单中删除所有选中商品']
		
		langid = parseInt(@languageid,10)
		result = if langid is 1 then key else data[key][langid-2]
		result

	toPinyin:(key)->
		if @languageid isnt 2 then CC2PY.toPinyin(key) else key
			
module.exports = Default
