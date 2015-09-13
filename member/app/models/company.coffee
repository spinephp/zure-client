Spine = require('spine')
Person = require('models/person')
require('spine/lib/ajax')
require('spine/lib/relation')

# 创建企业模型
class Company extends Spine.Model
	@configure 'Company', 'id',"name","address","bank","account","email","www","tel","fax","postcard","duty"
	@extend Spine.Model.Ajax
	#@hasMany 'persons', 'models/Person'
	@url: 'index.php? cmd=Company'

	@append:(ids)->
		fields = @attributes
		condition = [{field:"id",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false if data.length > 0


module.exports = Company
