Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class Billfree extends Spine.Model
	@configure 'Billfree', 'id','names'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=BillFree'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?",operator:"eq"}]
		token = $.fn.cookie 'PHPSESSID'
		params or= { data: $.param({ cond:condition,filter: fields, token:token }) }
		super(params)

	@current:null

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current
		@current

module.exports = Billfree
