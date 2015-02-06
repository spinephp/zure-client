Spine = require('spine')
require('spine/lib/ajax')

# ���վ�ģ��
class TheOrderState extends Spine.Model
	@configure 'TheOrderState', 'id','orderid','time','stateid'

	@extend Spine.Model.Ajax

	@url: '? cmd=OrdersState'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"orderid",value:$.getUrlParam("orderid"),operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = TheOrderState
