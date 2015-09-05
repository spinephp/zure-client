Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Sysnotice extends Spine.Model
	@configure 'Sysnotice', 'id',"type","content","time","readstate"
	@extend Spine.Model.Ajax
	@url: '? cmd=SystemNotice'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:'?userid',operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Sysnotice
