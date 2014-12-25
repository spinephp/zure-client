Spine	= require('spine')
Klass = require('models/goodclass')
Default = require('models/default')

$		= Spine.$

class Goodclass extends Spine.Controller
	className: 'goodclass'
  
	constructor: ->
		super
		@active @change
		
		@goodclass = $.Deferred()
		@default = $.Deferred()
		Klass.bind "refresh",=>@goodclass.resolve()
		Default.bind "refresh",=>@default.resolve()
  
	render: ->
		@html require("views/goodclasses")(@item)
		$(".imagesets .imgscroll").jCarouselLite
			btnNext: ".imagesets .next"
			btnPrev: ".imagesets .prev"
		#$(@btnCare).attr('disabled',"true") if Productcare.count() < 2
	
	change: (params) =>
		try
			$.when(@goodclass,@default).done =>
				if Klass.exists params.id
					@item = 
						goodclass:Klass.find params.id
						childs:Klass.select (item)=> parseInt(item.parentid) is parseInt params.id
						default:Default.first()
					@render()
		catch err
			@log "file: good.option.class.coffee\nclass: Goodclass\nerror: #{err.message}"

module.exports = Goodclass