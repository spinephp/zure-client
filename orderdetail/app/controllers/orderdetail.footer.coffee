Spine   = require('spine')
$       = Spine.$

class Footers extends Spine.Controller
	className: 'footers'
  
	constructor: ->
		super
	
		Spine.bind('headerrender', @render)

	render: (res) =>
		try
			@html require('views/showfooter')({items:res})
		catch err
			console.log err
	
module.exports = Footers