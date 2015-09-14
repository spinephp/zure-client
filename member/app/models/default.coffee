Spine = require('spine')
CC2PY = require('controllers/cc2py')

# 创建黙认模型
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
			'My concern':['我的关注']


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
			
			# loginDialog
			'Enter username':['输入用户名']
			'Enter password':['输入密码']
			'Enter char in box':['输入右框中的字符']
			'Click get another pin':['点击重新获取验证码']
			'Forget password':['忘记密码']
			'Custom login':['用户登录']
			'Invalid username':['无效的用户名']
			'Invalid password':['无效的密码']
			'Invalid verify code':['无效的验证码']
			'Login':['登录']
			'Close':['关闭']
			
			# 我的云瑞
			'Welcome to YunRui':['云瑞欢迎您']
			'Member':['会员']
			'Account Security':['账户安全']
			'Balance':['余额']
			'Integral':['积分']
			'Voucher':['优惠卷']
			'Giffcard':['礼品卡']
			'My Orders':['我的订单']
			'Pending':['待处理']
			'To evaluate':['待评价']
			'Feel':['待晒单']
			'View all orders':['查看全部订单']
			'My concern goods':['我关注的商品']
			'Recently viewed goods':['最近浏览的商品']
			'Cutprice':['降价商品']
			'Promotion':['促销商品']
			'Spot Goods':['现货商品']
			'More':['更多']
			'have':['有']
			'Have':['有']
			'Evaluation':['评价']
			'None goods have concerned':['无关注的商品']
			
			# 我的订单
			'Order Recycle':['订单回收站']
			'Remaind':['便利提醒']
			'Waiting for payment':['待付款']
			'Confirmt':['待确认收货']
			'Picking':['待提货']
			'Good name,Good NO,Order NO':['商品名称、商品编号、订单编号']
			'Inquiry':['查询']
			'Order NO':['订单号']
			'Order Info':['订单信息']
			'Consignee':['收货人']
			'Amount':['订单金额']
			'All time':['全部时间']
			'3 months':['最近三个月']
			'This year':['今年内']
			'ago':['年以前']
			'All state':['全部状态']
			'Contract':['等待合同']
			'Finished':['已完成']
			'Cancel':['已取消']
			'Operation':['操作']
			'Order detail':['订单详情']
			'Del':['删除']
			'Buy next':['还要买']
			'Now you have no order':['你目前还没有订单']
			
			'Goods review/single':['产品评价/晒单']

			# 我的关注
			'Concern goods':['关注的产品']
			'Concern activities':['关注的活动']
			'Category filter':['类别']
			'Label filter':['标签']
			'Only show':['仅显示']
			'Unrestricted':['不限']
			'Silicon Nitride bonded':['氮化硅结合']
			'Silica bonded':['氧化硅结合']
			'Castable':['浇注料']

			# 产品类
			'Recommended to you based on your concerns':['根据您的关注为您推荐']

			# 产品
			'Code':['产品编号']
			'Price':['产品价格']
			'Evaluation':['评价']
			'Purchase quantity':['购买数量']
			'people to participate in the evaluation':['个人已参与评价']
			'Add to cart':['加入订单']
			'With focus on':['加关注']

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
		result

	toPinyin:(key)->
		if @languageid isnt 2 then CC2PY.toPinyin(key) else key
			
module.exports = Default
