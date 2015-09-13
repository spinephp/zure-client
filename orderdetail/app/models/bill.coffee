Spine = require('spine')
require('spine/lib/ajax')

# ����ֵ˰��Ʊģ��
class Bill extends Spine.Model
	@configure 'Bill', 'id','names'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Bill'

	@fetch: (params) ->
		token = $.fn.cookie 'PHPSESSID'
		params or= 
			data:{ filter: @attributes, token:token } 
			processData: true
		@ajax().fetch(params)
		true
	
	@current:null

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current
		@current

module.exports = Bill
