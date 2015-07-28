Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')
draw = require('controllers/draw')

$		= Spine.$
		
class DryingEdits extends Spine.Controller
	className: 'dryingedits'
	
	elements:
		"ul li span":"mainEl" # 画布元素
		".drylines":"canvasEl" # 画布元素
		".scale":"scaleEl"
		".scrollbar-track-x":"scrollTrackEl"
		".scrollbar-thumb-x":"scrollThumbEl"
		"fieldset span":"dryDataEl"
 		#"audio.music":"musicEl"
  
	events:
		'change select[name=scale]':'scaleEdited'
		'click .scrollbar-left':'ckScrollLeft' # 滚动条左按键点击事件处理程序
		'click .scrollbar-right':'ckScrollRight' # 滚动条右i按键点击事件处理程序
		"click .scrollbar-track-x":"ckScrollTrack" # 滚动条点击事件处理程序
  
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		Drymain.bind "refresh",=>@drymain.resolve()

		@stepScroll = 1
		@stepFigure = 1
		@maxScrollerThumb = 200
		@curLineStartTime = 0
		
		# 窗口尺寸改变事件处理，调整画布大小并重绘页面
		$(window).resize => 
			@render() if @item?
			
		@item = 
			drymains: null
			drydatas: []
		@render()
		

	scaleEdited:(e)->
		e.stopPropagation()
		scale = parseInt $(e.target).val()
		@item.drydatas = Drydata.all()
		@curDraw?.setScale(scale).drawTemperature(@item.drydatas)
			
	render: ->
		@html require("views/dryedit")(@item)
		$("body >header h2").text "????->????->????"
		@curDraw = new draw @canvasEl
		@curDraw.drawTemperature(@item.drydatas)
		$(@scrollTrackEl).width @curDraw.ruleTimeWidth
		@maxScrollerThumb = $(@scrollTrackEl).width() - 20
		@setScrollBar()
		@showDryParam Drydata.last() if Drydata.count()
		
	change: (params) =>
		try
			$.when(@drymain).done =>
				drymain = Drymain.findByAttribute 'state',0
				if drymain?
					datas = Drydata.findByAttribute 'mainid',drymain.id
					@checkData = setInterval ()=>
						@findNewData drymain.id
					, 10000 # 每10秒查寻一次数据
				else
					@start = setInterval @checkDryStart , 10000 # 每10秒查寻一次数据
				@item = 
					drymains:drymain
					drydatas:datas | []
				@render()
		catch err
			@log "file: sysadmin.drying.option.edit.coffee\nclass: DryingEdits\nerror: #{err.message}"
			
	checkDryStart:()->
		Drymain.getStart (data)->
			if data?
				@checkData = setInterval ()->
					@findNewData data.id
				, 10000 # 每10秒查寻一次数据
				$(@mainEl).eq(0).text data.starttime
				$(@mainEl).eq(1).text data.lineno
			else
				$(@mainEl).text "等待干燥开始..."
		clearInterval @start
			
	findNewData:(mainid)->
		Drydata.getNew mainid,(record,islast)=>
			@setScrollBar()
			if Drydata.first().eql record
				@curDraw?.moveToPoint record
				@curLine = record.mode
				@curLineStartTemperature = record.settingtemperature
			else
				@curDraw?.drawToPoint record
			if @curLine isnt record.mode 
				@curLine = record.mode 
				@curLineStartTime = record.time
			@showDryParam record if islast
				
	showDryParam:(record)->
		$(@dryDataEl).eq(0).text (record.settingtemperature >> 4).toString()
		$(@dryDataEl).eq(1).text (record.temperature >> 4).toString()
		$(@dryDataEl).eq(5).text parseInt(record.time / 360).toString()+":"+(parseInt(record.time/6) % 60).toString()
		$(@dryDataEl).eq(4).text parseInt((record.time - @curLineStartTime) / 360).toString()+":"+(parseInt((record.time - @curLineStartTime)/6) % 60).toString()
		color = 'green'
		str = '正常'
		if record.temperature - record.settingtemperature < -32
			color = 'yellow'
			str = '温度低！'
			if record.temperature - record.settingtemperature < -48
				str = '温度低, 暂停！'
				color = 'red'
		if record.temperature - record.settingtemperature > 32
			color = 'yellow'
			str = '温度高！'
			if record.temperature - record.settingtemperature > 48
				str = '温度高！！！'
				color = 'red'
		$(@dryDataEl).eq(3).css 'background',color
		$(@dryDataEl).eq(3).text str
		
	setScrollBar:=>
		@stepScroll = 1
		@lasttime = Drydata.last()?.time | 0
		if @lasttime < @maxScrollerThumb
			$(@scrollTrackEl).attr "disabled","disabled"
			$(@scrollThumbEl).width(0)
		else
			$(@scrollTrackEl).removeAttr("disabled")
			len = $(@scrollTrackEl).width()+@maxScrollerThumb-@lasttime
			if len < 0
				@stepScroll = @maxScrollerThumb / (@lasttime-$(@scrollTrackEl).width())
			len = 9 if len < 9
			$(@scrollThumbEl).width len
	
	ckScrollTrack:(e)->
		e.stopPropagation()
		ox = e.offsetX-10
		ox = 0 if ox < 0
		ox = @maxScrollerThumb - $(@scrollThumbEl).width() if ox > @maxScrollerThumb - $(@scrollThumbEl).width()
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
		
module.exports = DryingEdits