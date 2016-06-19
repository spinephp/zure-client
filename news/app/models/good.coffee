Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class Good extends Spine.Model
	@configure 'Good', 'id','classid','size','picture','price','returnnow','cansale'

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Product'

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

module.exports = Good
