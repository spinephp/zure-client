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
			'Prices of goods':['降价商品']
			'My attention':['我的关注']


			'Go cart':['购物车']

			'The newest goods':['最新加入的商品']
			'Delete':['删除']
			'Orders containing':['订单包含']
			'kinds of products':['种产品']
			'A combined':['合计']
			'A total of':['共']
			'records':['个记录']
			'Order settlement':['订单结算']

			"AddFavorite":["加入收藏"]
			"SetHomepage":["设为首页"]
			'Home':["首页"]

			# 页脚
			'Address':["地址"]
			"ICP":["备案号"]
			"Copyright":["版权"]
			'All right reserved':["保留所有权利"]

			# 左边框
			'Company':['单位名称']
			'Tel':['电话']
			'Fax':['传真']
			'Business Department':['业务部']
			'Technology Department':['技术部']
			'Contact person':['联系人']

			# 产品类
			'Recommended to you based on your concerns':['根据您的关注为您推荐']

			# 产品
			'Goods infomation':['产品信息']
			'Code':['产品编号']
			'Category':['产品分类']
			'Subclass':['产品小类']
			'ITEM':['产品规格']
			'Rate':['产品评分']
			'Price':['产品价格']
			'Comments':['评价数']
			'Purchase':['购买数量']
			'Add to cart':['加入订单']

			# 产品评价
			'Member':['会员']
			'Review details':['评价详情']
			'Label':['标签']
			'Notes':['心得']
			'Buy date':['购买日期']
			'Useful':['有用']
			'Reply':['回复']
			'See the reply all':['查看全部回复']
			'No evaluation':['暂无评价']
			'First':['首页']
			'Prev':['上页']
			'Next':['下页']
			'Last':['尾页']

			'Login':["登录"]
			'Sign up':["注册"]
			'Name':["用户名"]
			'PWD':["密码"]
			'PIN':["验证码"]
			'Forget Password':["忘记密码"]
			'More':["更多"]
			'News':["新闻"]
			'Contact':["联系方式"]
			'Tel':["电话"]
			'Fax':["传真"]
			'Email':["邮箱"]
			'Url':["网址"]
			'Click here to send a message to me':["点击这里给我发消息"]
			'Company profile':["公司简介"]
			'Product recommendations':['产品推荐']
			'Friendly link':['友情链接']
		
		langid = parseInt(@languageid,10)
		result = if langid is 1 then key else data[key][langid-2]
		result

	toPinyin:(key)->
		if @languageid isnt 2 then CC2PY.toPinyin(key) else key
			
module.exports = Default
