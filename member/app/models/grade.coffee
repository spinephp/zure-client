Spine = require('spine')
require('spine/lib/ajax')
require('spine/lib/relation')

# 创建企业模型
class Grade extends Spine.Model
	@configure 'Grade', 'id',"names","cost","image","rights"
	@extend Spine.Model.Ajax
	@url: '? cmd=Grade'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Grade
