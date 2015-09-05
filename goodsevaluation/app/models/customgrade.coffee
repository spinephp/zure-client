Spine = require('spine')
Grade = require('models/grade')
require('spine/lib/ajax')

# 创建企业模型
class Customgrade extends Spine.Model
	@configure 'Customgrade', 'id',"userid","gradeid"

	@extend Spine.Model.Ajax

	@url: '? cmd=CustomGrade'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	@append:(ids)->
		fields = @attributes
		condition = [{field:"userid",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false if data.length > 0

	getNames:->
		Grade.find(@gradeid).names
	getImage:->
		Grade.find(@gradeid).image

module.exports = Customgrade
