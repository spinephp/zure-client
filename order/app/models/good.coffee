Spine = require('spine')
require('spine/lib/ajax')
Goodclass = require('models/goodclass')
Goodeval = require('models/goodeval')

# 创增值税发票模型
class Good extends Spine.Model
	@configure 'Good', 'id','classid','size','length','width','think','unitlen','unitwid','unitthi','picture','unit','sharp','weight','price','returnnow','amount','cansale','physicoindex','chemicalindex'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Product'

	@fetch: (params) ->
		fields = @attributes
		# condition = [{ field: 'homeshow',value: 'Y',operator:'eq' }]
		params or= 
			data:{filter: fields,token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	encodeId:->
		str = @id.toString()
		str = '0'+str while str.length<8
		str
	names:->
		item = Goodclass.find @classid
		item.names

	kindNames:->
		item = Goodclass.find @classid
		item.kindNames()

	longName:->
		item = Goodclass.find @classid
		item.longName()

module.exports = Good
