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
			'Prices of middles':['降价商品']
			'My attention':['我的关注']


			'Go cart':['购物车']

			'The newest middles':['最新加入的商品']
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

			# 发表晒单
			'Sun single':["发表晒单"]
			'Choose single commodity':["选择晒单商品"]
			'Title':["标题"]
			'Content':["内容"]
			'Can enter 10000 characters':["还能输入10000个字符"]
			'Upload images':["上传图片"]
			'Upload':["上传"]
			'Please upload 3-20 images, each image is less than 4m, support the image format of JPG, jpeg, BMP, PNG, GIF,          Hold down the "Ctrl" key, can choose more than one at a time;':["请上传3-20张图片，每张图片不超过4M，支持的图片格式为jpg，jpeg，bmp，png，gif； 按住“Ctrl”键，可一次选择多张；"]
			'About sun single':["关于晒单帖"]
			'You can use your own feeling, suggested the choose and buy, real photos, usage scenarios, such as the unpacking process and sharing;':["您可以将自己的使用感受、选购建议、实物照片、使用场景、拆包过程等与网友们分享；"]
			'Each item top 10 successful bask in single and number of pictures in three or more customers can get 100 points;':["每个商品前10位成功晒单者且图片数在3张及以上的客户可获得100个积分;"]
			'Please make sure that the uploaded pictures of original and legitimate, otherwise YunRui shall have the right to delete pictures and frozen account, and reserves the right to pursue its legal responsibility;':["请保证所上传的图片是原创的及合法的，否则云瑞有权删除图片及冻结帐号，且保留追究其法律责任的权利；"]
			'More sun single description':["更多晒单说明"]
			'Submit':["提交"]
		
		langid = parseInt(@languageid,10)
		result = if langid is 1 then key else data[key][langid-2]
		result

	toPinyin:(key)->
		if @languageid isnt 2 then CC2PY.toPinyin(key) else key
			
module.exports = Default
