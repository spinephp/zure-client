Spine = require('spine')
require('spine/lib/ajax')

# �����ͷ�ʽģ��
class Transport extends Spine.Model
	@configure 'Transport', 'id', 'name', 'note','charges'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Transport'

	@fetch: (params) ->
		params or= 
			data:{ filter:  @attributes, token: sessionStorage.token } 
			processData: true
		super(params)

	@current:null

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current
		@current

module.exports = Transport
