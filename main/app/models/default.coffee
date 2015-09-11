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
			'A total of':['共']
			'records':['个记录']
			'Order settlement':['订单结算']

			"AddFavorite":["加入收藏"]
			"SetHomepage":["设为首页"]
			'Home':["首页"]

			# 注册对话框
			'Custom register':["用户注册"]
			'Char':["字符"]
			'Verify':["验证"]
			'Strength':["密码强度"]
			'RE-PWD':["重输密码"]
			'Enter char in box':['输入右框中的字符']
			'Click get another pin':['点击重新获取验证码']
			'e.g.':['如']
			'Ditto':['同上']
			'Close':['关闭']
			'Pass':['通过']
			'Short':['太短']
			'Same user name':['与用户名相同']
			'General':['一般']
			'Very good':['很好']
			'Weak':['弱']
			'Password format error':['密码格式错误']
			'User name already exists':['用户名已存在']
			'Email format error':['邮箱格式错误']
			'Invalid phone number':['无效的手机号码']
			'Invalid telephone number':['无效的电话号码']
			'Invalid user name':['无效的用户名']
			'User name can not be empty':['用户名不能为空']
			'User name cannot begin with a number':['用户名不能以数字开头']
			'Valid length 6-18 characters':['合法长度为6-18个字符']
			'The user name can only contain _, English letters, numbers':['用户名只能包含_,英文字母,数字']
			'User name can only be the end of the English letters or numbers':['用户名只能英文字母或数字结尾']
			'The two passwords you typed are not consistent. \n please re-enter.':['分别键入的两个密码不一致!\n请重新输入。']
			'Error form submission, please try again later':['表单提交出错，请稍候再试']
			'Congratulations,':['恭喜您，']
			'Verify code error, please fill in.':['验证码错误，请重新填写。']
			
			# 页脚
			'Address':["地址"]
			"ICP":["备案号"]
			"Copyright":["版权"]
			'All right reserved':["保留所有权利"]

			'Home':["首页"]
			'Login':["登录"]
			'Sign up':["注册"]
			'Name':["用户名"]
			'PWD':["密码"]
			'PIN':["验证码"]
			'Forget Password':["忘记密码"]
			'My Order':['我的订单']
			'Logout':['退出']
			'More':["更多"]
			'News':["新闻"]
			'Contact':["联系方式"]
			'Tel':["电话"]
			'Fax':["传真"]
			'Mobile':["手机"]
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
