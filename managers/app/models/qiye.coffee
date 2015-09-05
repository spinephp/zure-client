Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Qiye extends Spine.Model
	@configure 'Qiye', 'id',"name","name_en","domain","qq","tel","fax","address","address_en","email","techid","busiid","icp","exchangerate"


	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Qiye'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"id",value:"1",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Qiye
