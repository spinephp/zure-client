Spine = require('spine')
require('spine/lib/ajax')

class Header extends Spine.Model
	@configure 'Header','name','data'
  
	@extend Spine.Model.Ajax
	@url:'? cmd=ContactHomeToJSON'

module.exports = Header