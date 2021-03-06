Spine	= require('spine')

$		= Spine.$
class draw
	constructor: (canvas) ->
		@canvas = canvas
		@ruleTemperatureWidth = 50
		@ruleTimeHeight = 35
		@scale = 0
		@offsetX = 0
		@unit = 1
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
	
	# 画查看线
	drawSeeLine:(x)->
		#@ctxSee.width = @ctxSee.width
		@ctxSee.setTransform 1,0,0,1,0,0
		@ctxSee.beginPath()
		@ctxSee.moveTo x,@canvas[1].height
		@ctxSee.lineTo x,0
		@ctxSee.strokeStyle = "rgba(0,0,0,0.5)"
		@ctxSee.stroke()
		parseInt((x+@offsetX)*@unit*60/@xSpace) # 返回当前平移和缩放参数下的 x 坐标(时间)
	
	# 擦查看线
	removeSeeLine:(x)->
		@ctxSee.clearRect x-1,0,x+1,@canvas[1].height
	
	# 画温度线
	drawTemperature:(recs)->
		@ctx.lineWidth = 1
		@ctx.beginPath()
		rote = @unit*60/@xSpace
		for rec,i in recs when rec.time > @offsetX*rote
			t = rec.temperature >> 4
			x = rec.time/rote-@offsetX+@ruleTemperatureWidth
			y = @ruleTemperatureHeight-(t+50)*@space/10
			if i > 0
				@ctx.lineTo x,y
			else
				@ctx.moveTo x ,y
		@ctx.strokeStyle = "red"
		@ctx.stroke()
		
		@ctx.beginPath()
		for rec,i in recs when rec.time > @offsetX*rote
			t = rec.settingtemperature >> 4
			x = rec.time/rote-@offsetX+@ruleTemperatureWidth
			y1 = @ruleTemperatureHeight-(t+50)*@space/10
			if i >0
				@ctx.lineTo x,y1
			else
				@ctx.moveTo x ,y1
		@ctx.strokeStyle = "blue"
		@ctx.stroke()
		@current_point = [x,y,y1]
			
	calcCoord:(rec)->
		rote = @unit*60/@xSpace
		t = rec.temperature >> 4
		#x = (rec.time-@offsetX*@unit)/rote+@ruleTemperatureWidth
		x = rec.time/rote-@offsetX+@ruleTemperatureWidth
		y = @ruleTemperatureHeight-(t+50)*@space/10
		t = rec.settingtemperature >> 4
		y1 = @ruleTemperatureHeight-(t+50)*@space/10
		[x,y,y1]
			
	moveToPoint:(rec)->
		@current_point = @calcCoord rec
			
	_drawLine:(coord,whitch_line)->
		@ctx.beginPath()
		@ctx.moveTo @current_point[0],@current_point[whitch_line]
		@ctx.lineTo coord[0],coord[whitch_line]
		@ctx.strokeStyle = ["red","blue"][whitch_line-1]
		@ctx.stroke()
	
	drawToPoint:(rec)->
		@ctx.lineWidth = 1
		coord = @calcCoord rec
		@_drawLine coord,1
		@_drawLine coord,2
		@current_point = coord
	
	resize:()->
		h = 450
		w = $(@canvas).parent().width()
		@canvas[0].width = w
		@canvas[0].height = h
		@canvas[1].width = w- 50
		@canvas[1].height = h - 35
		@ruleTemperatureHeight = h - @ruleTimeHeight
		@ruleTimeWidth = w - @ruleTemperatureWidth
		@ctx = @canvas[0].getContext "2d"
		@ctxSee = @canvas[1].getContext "2d"
		@ctx.width = @ctx.width
		@drawRuleTemperature()
		@drawRuleTime()
		
	getScale:()->
		@unit
		
	setScale:(value)->
		@scale = parseInt value
		@resize()
		@
		
	setOffset:(value)->
		@offsetX = parseInt value
		@resize()
		@
	@current_point:[0,0,0]
	
module.exports = draw