Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Productlabel extends Spine.Model
	@configure 'Productlabel', 'id',"names"

	@extend Spine.Model.Ajax

	@url: '? cmd=ProductLabel'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Productlabel
