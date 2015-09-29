Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Sysnotice extends Spine.Model
	@configure 'Sysnotice', 'id',"type","content","time","readstate"
	@extend Spine.Model.Ajax
	@url: 'woo/index.php? cmd=SystemNotice'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:'?userid',operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Sysnotice
