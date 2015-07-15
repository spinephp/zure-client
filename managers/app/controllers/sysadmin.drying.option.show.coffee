Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$
class draw
	constructor: (canvas) ->
		@canvas = canvas
		@ruleTemperatureWidth = 30
		@ruleTimeHeight = 30
		@resize()

	drawRuleTemperature:()->
		space = @ruleTemperatureHeight / 20
		x0 = @ruleTemperatureWidth - 10
		x1 = @ruleTemperatureWidth
		@ctx.strokeStyle = "rgba(0,0,0,0.5)"
		@ctx.lineWidth = 1
		for y in [@ruleTemperatureHeight..0] by -space
			console.log y
			#@ctx.beginPath()
			@ctx.moveTo x0,y
			@ctx.lineTo x1,y
			@ctx.stroke()
			
	resize:()->
		width = $("body").outerWidth()-$(".sizebar").outerWidth()-$(".dryingtrees").outerWidth()-$(".vdivide").outerWidth()*2
		height = 450
		$(@canvas).width = width
		$(@canvas).height = height
		@ruleTemperatureHeight = $(@canvas).height - 30
		@ruleTimeWidth = $(@canvas).width - 30
		console.log $(@canvas)
		@ctx = $(@canvas)[0].getContext "2d"
		@drawRuleTemperature()
		
class DryingShows extends Spine.Controller
	className: 'dryingshows'
	
	elements:
		"canvas":"canvasEl"
  
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		@drydata = $.Deferred()
		Drymain.bind "refresh",=>@drymain.resolve()
		Drydata.bind "refresh",=>@drydata.resolve()
		@curDraw = new draw @canvasEl
		
		# 窗口尺寸改变事件处理，调整画布大小并重绘页面
		$(window).resize => 
			@curDraw.resize()
		
	render: ->
		@html require("views/dryshow")(@item)
		$("body >header h2").text "????->????->????"
		@curDraw.drawRuleTemperature()
		
	change: (params) =>
		try
			$.when(@drymain,@drydata).done =>
				if Drymain.exists params.id
					drymain = Drymain.find params.id
					datas = Drydata.findByAttribute 'mainid',params.id
					unless datas?
						condition = [{field:"mainid",value:params.id,operator:"eq"}]
						token =  $.fn.cookie 'PHPSESSID'
						params = 
							data:{ filter: Drydata.attributes,cond:condition,token:token}
							processData: true

						Drydata.fetch params
					@item = 
						drymains:drymain
						drydatas:datas
					@render()
		catch err
			@log "file: sysadmin.drying.option.show.coffee\nclass: DryingShows\nerror: #{err.message}"
 
module.exports = DryingShows