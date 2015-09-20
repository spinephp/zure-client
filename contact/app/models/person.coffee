Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Person extends Spine.Model
	@configure 'Person', 'id',"username","picture","nick",'country',"name","email","tel","qq"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Person'

	@append:(ids)->
		fields = @attributes
		condition = [{field:"id",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false if data.length > 0


module.exports = Person
