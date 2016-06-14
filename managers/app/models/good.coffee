Spine = require('spine')
require('spine/lib/ajax')
Goodclass = require('models/goodclass')

# 创增值税发票模型
class Good extends Spine.Model
	@configure 'Good', 'id','classid','length','width','think','unitlen','unitwid','unitthi','size','picture','unit','sharp','weight','homeshow','price','returnnow','amount','cansale','status','note'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Product'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	longName:->
		item = Goodclass.find @classid
		item.longName()

module.exports = Good
