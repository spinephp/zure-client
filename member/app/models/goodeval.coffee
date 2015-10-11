Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Goodeval extends Spine.Model
	@configure 'Goodeval', 'id',"proid","userid","label","useideas","star","date","useful","status","images"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=ProductEval'
	@scope: 'woo/'

	@fetch: (params) ->
		params or= 
			data:{ filter: @attributes, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	@append:(ids)->
		fields = @attributes
		condition = [{field:"id",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false if data.length > 0

module.exports = Goodeval
