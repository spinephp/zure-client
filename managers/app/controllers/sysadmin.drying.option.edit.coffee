Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')
draw = require('controllers/draw')

$		= Spine.$
		
class DryingEdits extends Spine.Controller
	className: 'dryingedits'
	
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
		Drymain.bind "refresh",=>@drymain.resolve()

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
		@html require("views/dryedit")(@item)
		$("body >header h2").text "????->????->????"
		@curDraw = new draw @canvasEl
		@curDraw.drawTemperature(@item.drydatas)
		$(@scrollTrackEl).width $(@canvasEl).parent().width() - 50
		@maxScrollerThumb = $(@scrollTrackEl).width() - 20
		@setScrollBar()
		
	change: (params) =>
		try
			$.when(@drymain).done =>
				drymain = Drymain.findByAttribute 'state',0
				if drymain?
					datas = Drydata.findByAttribute 'mainid',drymain.id
					if datas?
						@item = 
							drymains:drymain
							drydatas:datas
						@render()
					@checkData = setInterval ()=>
						@findNewData drymain.id
					, 10000 # 每10秒查寻一次数据
				else
					@item = 
						drymains:null
						drydatas:[]
					@render()
					@start = window.setInterval @checkDryStart , 10000 # 每10秒查寻一次数据
					#if typeof(EventSource) isnt "undefined"
					#	source=new EventSource("/woo/view/drymain_sse.php")
					#	source.onmessage=(event)->     
					#		item = new Drymain event.data
					#		item.save ajax:false
					#else
					#	alert "Sorry, your browser does not support server-sent events..."
		catch err
			@log "file: sysadmin.drying.option.show.coffee\nclass: DryingShows\nerror: #{err.message}"
			
	checkDryStart:()->
		Drymain.getStart (data)->
			if data?
				@checkData = setInterval ()->
					@findNewData data.id
				, 10000 # 每10秒查寻一次数据
			else
				$("ul li span").text "等待干燥开始..."
		window.clearInterval @start
			
	findNewData:(mainid)->
		Drydata.getNew mainid,(record)->
			@setScrollBar()
			@curDraw.drawToPoint record

	setScrollBar:=>
		@lasttime = Drydata.last()?.time
		unless @lasttime? or @lasttime >= @maxScrollerThumb
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