Spine     = require('spine')
Manager = require('spine/lib/manager')
$            = Spine.$
Drymain = require('models/drymain')
Drydata = require('models/drydata')

Figures = require('controllers/sysadmin.dryingview.figure')
Headers = require('controllers/sysadmin.dryingview.header)

class Dryingview extends Spine.Controller
	className: 'dryingview'

	constructor: ->
		super
		@active @change

		@figures    = new Figures
		@headers    = new Headers
		
		Drymain.bind 'refresh',=>
			if Drymain.count()
				item = Drymain.first()
				condition = [{field:"mainid",value:item.id,operator:"eq"}]
				token =  $.fn.cookie 'PHPSESSID'
				params = 
					data:{ filter: Drydata.attributes,cond:condition,token:token} 
					processData: true

				Drydata.fetch params
			
		@append @headers,@figures
		
		Drymain.fetch()

	change: (params) ->
		@figures.active params
		@headers params
		
module.exports = Dryingview