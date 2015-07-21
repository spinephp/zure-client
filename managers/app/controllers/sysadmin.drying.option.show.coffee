Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')

$		= Spine.$
class draw
	constructor: (canvas) ->
		@canvas = canvas
		@ruleTemperatureWidth = 50
		@ruleTimeHeight = 35
		@scale = 0
		@offsetX = 0
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
		@xSpace = 60 # 每像素10秒，10分钟=60个像素，画一短标尺
		interval = 6
		@unit = 1
		switch @scale
			when 1
				@xSpace = @ruleTimeWidth / 12
				interval = 3
				@unit = 6
			when 2
				@xSpace= @ruleTimeWidth / 12
				interval = 3
				@unit = 12
			when 3
				@xSpace= @ruleTimeWidth / 12
				interval = 3
				@unit = 48
			else
				@xSpace = 60
				interval = 6
		y0 = @ruleTemperatureHeight
		y1 = @ruleTemperatureHeight+5
		@ctx.lineWidth = 1
		i = 0
		for sx in [@ruleTemperatureWidth...@ruleTimeWidth+@ruleTemperatureWidth+@offsetX] by @xSpace
			#@ctx.beginPath()
			linelen = 0
			x = sx - @offsetX
			unless i%(interval*@unit)
				s = ""
				linelen = 3
				if i < 60
					s += "0"
				s +=  (i/6).toString()+":00"
				@ctx.fillText s,x-15,y1+16 if x >= @ruleTemperatureWidth 
			if x >= @ruleTemperatureWidth
				@ctx.beginPath()
				@ctx.moveTo x ,y0
				@ctx.lineTo x,y1+ linelen
				@ctx.strokeStyle = "rgba(0,0,0,0.5)"
				@ctx.stroke()
			
			@ctx.beginPath()
			if i is 0
				@ctx.moveTo sx,y0
				@ctx.lineTo sx,0
				@ctx.strokeStyle = "rgba(0,0,0,0.5)"
			else
				@ctx.moveTo x,y0
				@ctx.lineTo x,0
				@ctx.strokeStyle = "rgba(200,200,200,0.5)"
			@ctx.stroke()
			i+=@unit
	
	# 画温度线
	drawTemperature:(recs)->
		@ctx.lineWidth = 1
		@ctx.beginPath()
		rote = @unit*60/@xSpace
		for rec,i in recs when rec.time > @offsetX*@unit
			t = rec.temperature >> 4
			x = (rec.time-@offsetX*@unit)/rote+@ruleTemperatureWidth
			y = @ruleTemperatureHeight-(t+50)*@space/10
			if i
				@ctx.lineTo x,y
			else
				@ctx.moveTo x ,y
		@ctx.strokeStyle = "red"
		@ctx.stroke()
		
		@ctx.beginPath()
		for rec,i in recs when rec.time > @offsetX*@unit
			t = rec.settingtemperature >> 4
			x = (rec.time-@offsetX*@unit)/rote+@ruleTemperatureWidth
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
		$(@canvas)[0].width = $(@canvas).parent().width()
		$(@canvas)[0].height = height
		@ruleTemperatureHeight = $(@canvas)[0].height - @ruleTimeHeight
		@ruleTimeWidth = $(@canvas)[0].width - @ruleTemperatureWidth
		@ctx = $(@canvas)[0].getContext "2d"
		@ctx.width = @ctx.width
		@drawRuleTemperature()
		@drawRuleTime()
		
	setScale:(value)->
		@scale = parseInt value
		@resize()
		@
		
	setOffset:(value)->
		@offsetX = parseInt value
		@resize()
		@
		
class DryingShows extends Spine.Controller
	className: 'dryingshows'
	
	elements:
		".drylines":"canvasEl" # 画布元素
		".scale":"scaleEl"
		".scrollbar-track-x":"scrollTrackEl"
		".scrollbar-thumb-x":"scrollThumbEl"
  
	events:
		'change select[name=scale]':'scaleEdited'
		'click .scrollbar-left':'ckScrollLeft'
		'click .scrollbar-right':'ckScrollRight'
		"click .scrollbar-track-x":"ckScrollTrack"
  
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		@drydata = $.Deferred()
		Drymain.bind "refresh",=>@drymain.resolve()
		Drydata.bind "refresh",=>@drydata.resolve()

		@stepScroll = 1
		@stepFigure = 1
		@maxScrollerThumb = 200
		
		# 窗口尺寸改变事件处理，调整画布大小并重绘页面
		$(window).resize => 
			@render()
		

	scaleEdited:(e)->
		e.stopPropagation()
		scale = parseInt $(e.target).val()
		@curDraw?.setScale(scale).drawTemperature(@item.drydatas)
			
	render: ->
		@html require("views/dryshow")(@item)
		$("body >header h2").text "????->????->????"
		@curDraw = new draw @canvasEl
		@curDraw.drawTemperature(@item.drydatas)
		$(@scrollTrackEl).width $(@canvasEl).parent().width() - 50
		@maxScrollerThumb = $(@scrollTrackEl).width() - 30
		
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
							@setScrollBar()
							@item = 
								drymains:drymain
								drydatas:Drydata.all()
							@render()

						Drydata.fetch params
					else
						@setScrollBar()
						@item = 
							drymains:drymain
							drydatas:datas
						@render()
		catch err
			@log "file: sysadmin.drying.option.show.coffee\nclass: DryingShows\nerror: #{err.message}"
			
	setScrollBar:->
		@lasttime = Drydata.last().time
		if @lasttime < @maxScrollerThumb
			$(@scrollTrackEl).attr "disabled","disabled"
			$(@scrollThumbEl).width(0)
		else
			$(@scrollTrackEl).removeAttr("disabled")
			len = $(@scrollTrackEl).width()+@maxScrollerThumb-@lasttime
			if len < 0
				@stepScroll = @maxScrollerThumb / (@lasttime-$(@scrollTrackEl).width())
			else
				@stepScroll = 1
			
			len = 9 if len < 9
			$(@scrollThumbEl).width len
	
	ckScrollTrack:(e)->
		e.stopPropagation()
		console.log e
		ox = e.clientX-10
		#ox *= @stepScroll
		ox = 0 if ox < 0
		$(@scrollThumbEl).css('left':ox.toString()+'px')
		@curDraw?.setOffset(ox*@stepFigure).drawTemperature(@item.drydatas)
	
	ckScrollLeft:(e)=>
		e.stopPropagation()
		ox = $(@scrollThumbEl).position().left - 10
		ox -= @stepScroll
		ox = 0 if ox < 0
		$(@scrollThumbEl).css('left':ox.toString()+'px')
		@curDraw?.setOffset(ox*@stepFigure).drawTemperature(@item.drydatas)

	ckScrollRight:(e)=>
		e.stopPropagation()
		ox = $(@scrollThumbEl).position().left-10
		ox += @stepScroll
		$(@scrollThumbEl).css('left':ox.toString()+'px') if ox < @maxScrollerThumb
		@curDraw?.setOffset(ox*@stepFigure).drawTemperature(@item.drydatas)
		
module.exports = DryingShows