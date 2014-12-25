Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Chemicalindex extends Spine.Model
	@configure 'Chemicalindex', 'id',"sic","si3n4","sio2","si","fe2o3","cao","al2o3"

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Chemicalindex'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

module.exports = Chemicalindex
