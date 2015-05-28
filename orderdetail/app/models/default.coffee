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
			
			# 添加订单对话框
			"The order added successfully":["订单添加成功"]
			"Add order":["添加订单"]
			"Close":["关闭"]
			
			"AddFavorite":["加入收藏"]
			"SetHomepage":["设为首页"]
			'Home':["首页"]

			# 页脚
			'Address':["地址"]
			"ICP":["备案号"]
			"Copyright":["版权"]
			'All right reserved':["保留所有权利"]

			# 订单
			'Goods list':['商品清单']
			'Return and edit order':['返回修改购物车']
			'Item':['商品']
			'Price':['云瑞价']
			'Return now':['返现/送积分']
			'Quantity':['数量']
			'Shipping date':['供货时间']
			'Goods code':['商品编号']
			'In stock':['现货']
			'45 days':['45 天']
			'A total of':['共']
			'PCS':['件']
			'Amount':['总商品金额']
			'Freight':['运费']
			'Amount payable':['应付总额']
			'Submit':['提交订单']

			# 产品类
			'Recommended to you based on your concerns':['根据您的关注为您推荐']

			# 产品
			'Code':['产品编号']
			'Price':['产品价格']
			'Evaluation':['产品评价']
			'Purchase quantity':['购买数量']
			'people to participate in the evaluation':['个人已参与评价']
			'Add to cart':['加入订单']
			'With focus on':['加关注']
			'successful':['成功']
			'The products of you with focus on already have done.':['该产品你已关注过了。']
			
			'Introduction':['产品介绍']
			'Parameters':['详细参数']
			'Physicochemical index':['理化指标']
			'Physico index':['物理指标']
			'Chemical index':['化学指标']
			'Material':['材质']
			'Name':['名称']
			'Type':['类型']
			'Weight':['重量']
			'Shape':['形状']
			'Length':['长度']
			'Width':['宽度']
			'Think':['厚度']
			'ITEM':['项目']
			'UNIT':['单位']
			'SPEC':['指标']
			'ENVIRONMENT':['测试条件']

			# 产品评价
			'Good':['好评']
			'Medium':['中评']
			'Poor':['差评']
			'Number':['会员']
			'Good rate':['好评率']
			'Buyers impression':['买家印象']
			'For purchased goods':['对已购商品可评价']
			'Evaluation and integral':['评价拿积分']
			'Integral rules':['积分规则']
			'All evaluation':['所有评价']
			'Label':['标签']
			'Notes':['心得']
			'Single':['晒单']
			'pictures':['张图片']
			'View the single':['查看晒单']
			'Buy date':['购买日期']
			'Useful':['有用']
			'Reply':['回复']
			'See the reply all':['查看全部回复']
			'No evaluation':['暂无评价']
			'First':['首页']
			'Prev':['上页']
			'Next':['下页']
			'Last':['尾页']
			# 产品咨询
			'All consulting':['全部咨询']
			'Commodity':['商品咨询']
			'Inventory distribution':['库存配送']
			'Pay':['支付']
			'Invoice warranty':['发票保修']
			'Payment to help':['支付帮助']
			'Please search before consulting, convenient and fast':['咨询前请先搜索，方便又快捷']
			'Warm prompt: the following reply to the questioner only valid for 3 days, other netizens are for reference only! If to inconvenience you please understanding a lot from this, thank you!':['温馨提示:以下回复仅对提问者3天内有效，其他网友仅供参考！若由此给您带来不便请多多谅解，谢谢！']
			'Net friend':['网友']
			'Question':['咨询内容']
			'No consulting':['暂无咨询']
			'Before buying, if you have any questions, please contact':['购买之前，如有问题，请咨询']
			'or':['或']
			'Advisory':['发表咨询']
			'A total of':['共']
			'records':['条']
			'Browse all':['浏览所有咨询信息']

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
		result or key

	toPinyin:(key)->
		if @languageid isnt 2 then CC2PY.toPinyin(key) else key
			
module.exports = Default
