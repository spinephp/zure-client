Spine = require('spine')
require('spine/lib/ajax')

# 创支付方式模型
class Payment extends Spine.Model
	@configure 'Payment', 'id', 'name', 'note', 'url', 'urltext'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Payment'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie "PHPSESSID" } 
			processData: true
		super(params)

	@current:null

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current?
		@current 

module.exports = Payment