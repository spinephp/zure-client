Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$
class draw
	constructor: (canvas) ->
		@canvas = canvas
		@ruleTemperatureWidth = 50
		@ruleTimeHeight = 30
		@resize()

	drawRuleTemperature:()->
		space = @ruleTemperatureHeight / 25
		x0 = @ruleTemperatureWidth - 5
		x1 = @ruleTemperatureWidth
		@ctx.strokeStyle = "rgba(0,0,0,0.5)"
		@ctx.lineWidth = 1
		i = -50
		for y in [@ruleTemperatureHeight..20] by -space
			#@ctx.beginPath()
			linelen = 0
			unless i%50
				linelen = 3
				s =  i.toString()
				x = 15 + (3-s.length)*8
				@ctx.fillText i.toString(),x,y+4
			@ctx.moveTo x0 - linelen,y
			@ctx.lineTo x1,y
			@ctx.stroke()
			i += 10
			
	resize:()->
		width = $("body").outerWidth()-$(".sizebar").outerWidth()-$(".dryingtrees").outerWidth()-$(".vdivide").outerWidth()*2
		height = 450
		$(@canvas)[0].width = width
		$(@canvas)[0].height = height
		@ruleTemperatureHeight = $(@canvas)[0].height - @ruleTimeHeight
		@ruleTimeWidth = $(@canvas)[0].width - @ruleTemperatureWidth
		console.log $(@canvas)
		@ctx = $(@canvas)[0].getContext "2d"
		@drawRuleTemperature()
		
class DryingShows extends Spine.Controller
	className: 'dryingshows'
	
	elements:
		".drylines":"canvasEl"
  
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		@drydata = $.Deferred()
		Drymain.bind "refresh",=>@drymain.resolve()
		Drydata.bind "refresh",=>@drydata.resolve()
		
		# 窗口尺寸改变事件处理，调整画布大小并重绘页面
		$(window).resize => 
			@curDraw.resize()
		
	render: ->
		@html require("views/dryshow")(@item)
		$("body >header h2").text "????->????->????"
		@curDraw = new draw @canvasEl
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