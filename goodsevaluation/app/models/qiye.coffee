Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Qiye extends Spine.Model
	@configure 'Qiye', 'id',"names","domain","qq","tel","fax","addresses","email","techid","busiid","introductions","icp"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Qiye'
	@scope:'woo/'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"id",value:"1",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Qiye
