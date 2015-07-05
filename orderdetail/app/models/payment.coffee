Spine = require('spine')
require('spine/lib/ajax')

# ��֧����ʽģ��
class Payment extends Spine.Model
	@configure 'Payment', 'id', 'names', 'note', 'url', 'urltext'

	@extend Spine.Model.Ajax

	@url: '? cmd=Payment'

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

module.exports = Payment