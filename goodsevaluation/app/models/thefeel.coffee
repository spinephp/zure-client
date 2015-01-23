Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Gooduse extends Spine.Model
	@configure 'Gooduse', 'id',"proid","userid","title","content","images","date","status"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=ProductUse'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	@append:(ids)->
		fields = @attributes
		condition = [{field:"id",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false #if data.length > 0
module.exports = Gooduse
