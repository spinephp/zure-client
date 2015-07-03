Spine   = require('spine')
Drymain = require('models/drymain')

$       = Spine.$

class Dryingheader extends Spine.Controller
	className: 'dryingheader'
  
	constructor: ->
		super
		@active @change

		@drymain = $.Deferred()

		Drymain.bind "refresh",=>@drymain.resolve()
		Drymain.bind "change",=>
			@item.drymain=Drymain.first()
			@render()
 
	render: =>
		@html require("views/dryingheader")(@item)
	
	change: (params) =>
		try
			$.when( @drymain).done =>
				if Drymain.count()
					@item = 
						drymain:Drymain.first()
					@render()
				else
					if typeof(EventSource) isnt "undefined"
						source=new EventSource("/woo/view/drymain_sse.php")
						source.onmessage=(event)->     
							item = new Drymain event.data
							item.save()
					else
						alert "Sorry, your browser does not support server-sent events..."
				
		catch err
			@log "file: sysadmin.progress.infomation.coffee\nclass: Dryingheader\nerror: #{err.message}"

module.exports = Dryingheader