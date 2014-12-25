Spine = require('spine')
require('spine/lib/ajax')

class Mainmenu extends Spine.Model
	@configure 'Mainmenu','names','command'
  
	@extend Spine.Model.Ajax
	@url:'? cmd=Navigation'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{filter: fields, token: sessionStorage.token } 
			processData: true
		super(params)

module.exports = Mainmenu