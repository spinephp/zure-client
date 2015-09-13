Spine = require('spine')
require('spine/lib/ajax')

# 创建增值税模型
class Billsale extends Spine.Model
	@configure 'Billsale','id','names','address','tel','duty','bank','account'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=BillSale'

	@fetch: (params) ->
		condition = [{field:"userid",value:"?",operator:"eq"}]
		token = $.fn.cookie 'PHPSESSID'
		params or= 
			data:{ cond:condition,filter:@attributes,token:token } 
			processData: true

		super(params)

	@current:null

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current
		@current

	titles: ->
		{name:"单位名称",duty:"纳税人识别号",address:"注册地址",tel:"注册电话",bank:"开户银行",account:"银行帐户"}

module.exports = Billsale
