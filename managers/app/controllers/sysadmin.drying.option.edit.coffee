Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$

class DryingEdits extends Spine.Controller
	className: 'employeeedits'
  
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		@drydata = $.Deferred()
		Drymain.bind "refresh",=>@drymain.resolve()
		Drydata.bind "refresh",=>@drydata.resolve()
		Drymain.bind "change",=>
			@item.drymain=Drymain.first()
			@render()
  
	render: ->
		@html require("views/dryedit")(@item)
		$("body >header h2").text "劳资管理->员工管理->员工信息"
	
	change: (params) =>
		try
			$.when(@drymain,@drydata).done =>
				if Drymain.exists params.id
					drymain = Drymain.find params.id
					@item = 
						drymains:drymain
						drydatas:Edit
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
			@log "file: sysadmin.drying.option.edit.coffee\nclass: DryingEdits\nerror: #{err.message}"

module.exports = DryingEdits