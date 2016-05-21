Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class My extends Spine.Model
	@configure 'Person', 'id',"pwd","hash","lasttime"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Person'

	@fetch:()->
		fields = @attributes
		condition = [{field:"hash",value:$.getUrlParam('verify'),operator:'eq'}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false if data.length > 0


module.exports = My
