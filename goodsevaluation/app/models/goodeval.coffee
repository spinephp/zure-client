Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Goodeval extends Spine.Model
	@configure 'Goodeval', 'id','proid',"star"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=ProductEval'
	@scope:'woo/'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	@append:(ids)->
		fields = @attributes
		condition = [{field:"proid",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false if data.length > 0

	@stars:->
		start = 0
		start+=eval.star for eval in @all()
		start / @count()

module.exports = Goodeval
