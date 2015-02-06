Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class Billfree extends Spine.Model
	@configure 'Billfree', 'id','name'

	@extend Spine.Model.Ajax

	@url: '? cmd=BillFree'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?",operator:"eq"}]
		params or= { data: $.param({ cond:condition,filter: fields, token: sessionStorage.token }) }
		super(params)

	@current:null

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current
		@current

module.exports = Billfree
