Spine = require('spine')
require('spine/lib/ajax')

# 创建增值税模型
class Billcontent extends Spine.Model
	@configure 'Billcontent', 'id','names'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=BillContent'

	@fetch: (params) ->
		fields = @attributes
		token = $.fn.cookie 'PHPSESSID'
		params or= 
			data:{ filter: fields, token:token } 
			processData: true
		super(params)

	@current:null

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current
		@current

module.exports = Billcontent
