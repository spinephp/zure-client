Spine = require('spine')
require('spine/lib/ajax')
require('spine/lib/relation')

# ������ҵģ��
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
