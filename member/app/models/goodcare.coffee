Spine = require('spine')
require('spine/lib/ajax')
Good = require('models/good')

# 创建企业模型
class Goodcare extends Spine.Model
	@configure 'Goodcare', 'id',"proid","price","currencyid","exchangerate","date","label"
	@extend Spine.Model.Ajax
	@url: '? cmd=ProductCare'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:'?userid',operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

	productClassNames:->
		Good.find(@proid).classnames

	productNames:->
		Good.find(@proid).names

	productSize:->
		Good.find(@proid).size

	productImage:->
		Good.find(@proid).picture

	productPrice:->
		Good.find(@proid).price

	productAmount:->
		Good.find(@proid).amount

	productEval:->
		Good.find(@proid).eval

module.exports = Goodcare
