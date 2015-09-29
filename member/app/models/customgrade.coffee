Spine = require('spine')
Grade = require('models/grade')
require('spine/lib/ajax')

# 创建企业模型
class Customgrade extends Spine.Model
	@configure 'Customgrade', 'id',"gradeid","date"
	@extend Spine.Model.Ajax
	@url: 'woo/index.php? cmd=CustomGrade'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?userid",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	name:->
		Grade.find(@gradeid).names[sessionStorage.language]

	names:->
		Grade.find(@gradeid).names

	image:->
		Grade.find(@gradeid).image

	right:->
		Grade.find(@gradeid).rights

	nextName:->
		Grade.find(parseInt(@gradeid)+1).names[sessionStorage.language] if @gradeid < Grade.last().id

	nextNames:->
		Grade.find(parseInt(@gradeid)+1).names if @gradeid < Grade.last().id

	nextCost:->
		Grade.find(parseInt(@gradeid)+1).cost if @gradeid < Grade.last().id

	isLast:->
		@gradeid is Grade.last().id

module.exports = Customgrade
