Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Orderproduct extends Spine.Model
	@configure 'Orderproduct', 'id',"classid","size","picture"
	@extend Spine.Model.Ajax
	@url: '? cmd=Product'

	@append:(ids)->
		fields = @attributes
		condition = [{field:"id",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false if data.length > 0

module.exports = Orderproduct
