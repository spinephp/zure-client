Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class Bill extends Spine.Model
	@configure 'Bill', 'id','name'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=Bill'

	@fetch: (params) ->
		params or= 
			data:{ filter: @attributes, token: sessionStorage.token } 
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
