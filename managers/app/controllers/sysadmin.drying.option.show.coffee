Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$
class draw
	constructor: (canvas) ->
		@canvas = canvas
		@ruleTemperatureWidth = 50
		@ruleTimeHeight = 35
		@scale = 1
		@resize()
	
	# 画温度标尺
	drawRuleTemperature:()->
		@space = @ruleTemperatureHeight / 25
		x0 = @ruleTemperatureWidth - 5
		x1 = @ruleTemperatureWidth
		@ctx.lineWidth = 1
		i = -50
		for y in [@ruleTemperatureHeight..0] by -@space
			linelen = 0
			unless i%50
				linelen = 3
				s =  i.toString()
				x = 15 + (3-s.length)*8
				@ctx.fillText i.toString(),x,y+4
			@ctx.beginPath()
			@ctx.moveTo x0 - linelen,y
			@ctx.lineTo x1,y
			@ctx.strokeStyle = "rgba(0,0,0,0.8)"
			@ctx.stroke()
			
			@ctx.beginPath()
			@ctx.moveTo x1,y
			@ctx.lineTo $(@canvas)[0].width,y
			if i is -50
				@ctx.strokeStyle = "rgba(0,0,0,0.5)"
			else
				@ctx.strokeStyle = "rgba(200,200,200,0.5)"
			@ctx.stroke()
			i += 10
	
	# 画时间标尺
	drawRuleTime:()->
		space = 60 # 每像素10秒，10分钟=60个像素，画一短标尺
		y0 = @ruleTemperatureHeight
		y1 = @ruleTemperatureHeight+5
		@ctx.lineWidth = 1
		i = 0
		for x in [@ruleTemperatureWidth...@ruleTimeWidth+@ruleTemperatureWidth] by space
			#@ctx.beginPath()
			linelen = 0
			unless i%6
				s = ""
				linelen = 3
				if i < 60
					s += "0"
				s +=  (i/6).toString()+":00"
				@ctx.fillText s,x-15,y1+16
			@ctx.beginPath()
			@ctx.moveTo x ,y0
			@ctx.lineTo x,y1+ linelen
			@ctx.strokeStyle = "rgba(0,0,0,0.5)"
			@ctx.stroke()
			
			@ctx.beginPath()
			@ctx.moveTo x,y0
			@ctx.lineTo x,0
			if i is 0
				@ctx.strokeStyle = "rgba(0,0,0,0.5)"
			else
				@ctx.strokeStyle = "rgba(200,200,200,0.5)"
			@ctx.stroke()
			i++
	
	# 画温度线
	drawTemperature:(recs)->
		@ctx.lineWidth = 1
		@ctx.beginPath()
		for rec,i in recs
			t = rec.temperature >> 4
			x = rec.time+@ruleTemperatureWidth
			y = @ruleTemperatureHeight-(t+50)*@space/10
			if i
				@ctx.lineTo x,y
			else
				@ctx.moveTo x ,y
		@ctx.strokeStyle = "red"
		@ctx.stroke()
		
		@ctx.beginPath()
		for rec,i in recs
			t = rec.settingtemperature >> 4
			x = rec.time+@ruleTemperatureWidth
			y = @ruleTemperatureHeight-(t+50)*@space/10
			if i
				@ctx.lineTo x,y
			else
				@ctx.moveTo x ,y
		@ctx.strokeStyle = "blue"
		@ctx.stroke()
			
	resize:()->
		width = $("body").outerWidth()-$(".sizebar").outerWidth()-$(".dryingtrees").outerWidth()-$(".vdivide").outerWidth()*2
		height = 450
		$(@canvas)[0].width = width
		$(@canvas)[0].height = height
		@ruleTemperatureHeight = $(@canvas)[0].height - @ruleTimeHeight
		@ruleTimeWidth = $(@canvas)[0].width - @ruleTemperatureWidth
		@ctx = $(@canvas)[0].getContext "2d"
		@ctx.width = @ctx.width
		@drawRuleTemperature()
		@drawRuleTime()
		
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
			@render()
		
	render: ->
		@html require("views/dryshow")(@item)
		$("body >header h2").text "????->????->????"
		@curDraw = new draw @canvasEl
		#@curDraw.drawRuleTemperature()
		#@curDraw.drawRuleTime()
		@curDraw.drawTemperature(@item.drydatas)
		
	change: (params) =>
		try
			$.when(@drymain,@drydata).done =>
				if Drymain.exists params.id
					drymain = Drymain.find params.id
					datas = Drydata.findByAttribute 'mainid',params.id
					Drydata.destroyAll ajax:false
					unless datas?
						condition = [{field:"mainid",value:params.id,operator:"eq"}]
						token =  $.fn.cookie 'PHPSESSID'
						params = 
							data:{ filter: Drydata.attributes,cond:condition,token:token}
							processData: true
							
						Drydata.one "refresh",=>
							@item = 
								drymains:drymain
								drydatas:Drydata.all()
							@render()

						Drydata.fetch params
					else
						@item = 
							drymains:drymain
							drydatas:datas
						@render()
		catch err
			@log "file: sysadmin.drying.option.show.coffee\nclass: DryingShows\nerror: #{err.message}"
 
module.exports = DryingShows