Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Right extends Spine.Model
	@configure 'Right', 'id',"code","name"

	@extend Spine.Model.Ajax

	@url: '? cmd=Right'

	@fetch: (params) ->
		params or= 
			data:{ filter: @attributes, token:$.fn.cookie 'PHPSESSID' } 
			processData: true
		@ajax().fetch(params)
		true

module.exports = Right
