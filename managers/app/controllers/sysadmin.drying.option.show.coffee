Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')
draw = require('controllers/draw')

$		= Spine.$
		
class DryingShows extends Spine.Controller
	className: 'dryingshows'
	
	elements:
		"canvas":"canvasEl" # 画布元素
		".scale":"scaleEl"
		".scrollbar-track-x":"scrollTrackEl"
		".scrollbar-thumb-x":"scrollThumbEl"
		"fieldset span":"dryDataEl"
 		#"audio.music":"musicEl"

	events:
		'change select[name=scale]':'scaleEdited'
		'click .scrollbar-left':'ckScrollLeft'
		'click .scrollbar-right':'ckScrollRight'
		"click .scrollbar-track-x":"ckScrollTrack"
		"click .validate":"verifyCode"
		'click input[type=submit]': 'option'
		'mouseenter canvas:eq(1)': 'seeIn'
		'mouseleave canvas:eq(1)': 'seeOut'
		'mousemove canvas:eq(1)': 'seeNext'
 
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		@drydata = $.Deferred()
		Drymain.bind "refresh",=>@drymain.resolve()
		Drydata.bind "refresh",=>@drydata.resolve()

		@stepScroll = 1
		@stepFigure = 1
		@curLineStartTime = 0
		@maxScrollerThumb = 200
		@maxSettingTemperature = 0
		@maxTemperature =  0
		@start = null
		@checkData = null
		
		# 窗口尺寸改变事件处理，调整画布大小并重绘页面
		$(window).resize => 
			@render()
		
	scaleEdited:(e)->
		e.stopPropagation()
		scale = parseInt $(e.target).val()
		@curDraw?.setScale(scale).drawTemperature(@item.drydatas)
			
	render: ->
		@html require("views/dryshow")(@item)
		@curDraw = new draw @canvasEl
		@curDraw.drawTemperature(@item.drydatas)
		$(@scrollTrackEl).width $(@canvasEl).parent().width() - 50
		@maxScrollerThumb = $(@scrollTrackEl).width() - 20
		@setScrollBar()
		@findMaxTemperatureDiff @item.drydatas
	
	# 计算最大温差
	findMaxTemperatureDiff:(recs)->
		color = 'white'
		for record in recs
			dx = Math.abs( record.settingtemperature - record.temperature)
			if dx > Math.abs(@maxSettingTemperature - @maxTemperature)
				@maxSettingTemperature = record.settingtemperature
				@maxTemperature =  record.temperature
				if dx > 32
					color = 'yellow'
					if dx > 48
						color = 'red'
		$(@dryDataEl).eq(1).text (@maxSettingTemperature >> 4).toString()
		$(@dryDataEl).eq(3).text (@maxTemperature  >> 4).toString()
		$(@dryDataEl).eq(1).css 'background',color
		$(@dryDataEl).eq(3).css 'background',color
		
		
	change: (params) =>
		try
			unless params.id is '-1' # 显示干燥记录
				$.when(@drymain,@drydata).done =>
					if Drymain.exists params.id
						drymain = Drymain.find params.id
						if parseInt(drymain.state) > 0
							if @checkData?
								clearInterval  @checkData
								@checkData = null
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
									drydatas:Drydata.all()
								@render()
								$("body >header h2").text "生产管理->干燥管理->显示干燥记录"
			else # 干燥监控
				$.when(@drymain).done =>
					drymain = Drymain.findByAttribute 'state',0
					if drymain?
						datas = Drydata.findAllByAttribute 'mainid',drymain.id
						@checkData = setInterval ()=>
							@findNewData drymain.id
						, 10000 # 每10秒查寻一次数据
					else
						@start = setInterval @checkDryStart , 10000 # 每10秒查寻一次数据
					@item = 
						drymains:drymain
						drydatas:datas | []
					@render()
					$("body >header h2").text "生产管理->干燥管理->干燥监控"
			
		catch err
			@log "file: sysadmin.drying.option.show.coffee\nclass: DryingShows\nerror: #{err.message}"
			
	setScrollBar:=>
		@lasttime = Drydata.last()?.time or 0
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
		ox = e.offsetX-10
		ox = 0 if ox < 0
		ox = @maxScrollerThumb - $(@scrollThumbEl).width() if ox > @maxScrollerThumb - $(@scrollThumbEl).width()
		$(@scrollThumbEl).css('left':ox.toString()+'px')
		@curDraw?.setOffset(ox*@stepFigure).drawTemperature(@item.drydatas)
	
	# 处理水平滚动棒左箭头单击事件
	ckScrollLeft:(e)=>
		e.stopPropagation()
		ox = $(@scrollThumbEl).position().left - 10
		ox -= @stepScroll
		ox = 0 if ox < 0
		$(@scrollThumbEl).css('left':ox.toString()+'px')
		@curDraw?.setOffset(ox*@stepFigure).drawTemperature(@item.drydatas)

	# 处理水平滚动棒右箭头单击事件
	ckScrollRight:(e)=>
		e.stopPropagation()
		ox = $(@scrollThumbEl).position().left-10
		ox += @stepScroll
		$(@scrollThumbEl).css('left':ox.toString()+'px') if ox < @maxScrollerThumb
		@curDraw?.setOffset(ox*@stepFigure).drawTemperature(@item.drydatas)

	# 处理验证码单击事件
	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		key = $("form").serializeArray()
		Drymain.one "beforeDestroy", =>
			Drymain.url = "woo/index.php"+Drymain.url if Drymain.url.indexOf("woo/index.phjp") is -1
			Drymain.url += "&token="+ $.fn.cookie('PHPSESSID') unless Drymain.url.match /token/
			Drymain.url += "&#{field.name}=#{field.value}" for field in key when not Drymain.url.match "&#{field.name}="
		Drymain.one "ajaxSuccess", (status, xhr) => 
			Drymain.url = @url
			items = Drydata.findByAttribute 'mainid',@item.drymains.id
			items?.destroy ajax:false
		@item.drymains.destroy() if confirm("确实要删除 #{@item.drymains.starttime} 的干燥记录吗?")
	
	# 实时等待干燥开始
	checkDryStart:()->
		Drymain.getStart (data)->
			if data?
				@checkData = setInterval ()->
					@findNewData data.id
				, 10000 # 每10秒查寻一次数据
				$(@mainEl).eq(0).text data.starttime
				$(@mainEl).eq(1).text data.lineno
				if @start?
					clearInterval @start
					@start = null
			else
				$(@mainEl).text "等待干燥开始..."
	
	# 取实时干燥数据
	findNewData:(mainid)->
		Drydata.getNew mainid,(record,islast)=>
			@setScrollBar()
			if Drydata.first().eql record
				@curDraw?.moveToPoint record
				@curLine = record.mode
				@curLineStartTemperature = record.settingtemperature
				@maxSettingTemperature = record.settingtemperature
				@maxTemperature =  record.temperature
			else
				@curDraw?.drawToPoint record
				dx = Math.abs( record.settingtemperature - record.temperature)
				if dx > Math.abs(@maxSettingTemperature - @maxTemperature)
					@maxSettingTemperature = record.settingtemperature
					@maxTemperature =  record.temperature
					$(@dryDataEl).eq(1).text (record.settingtemperature >> 4).toString()
					$(@dryDataEl).eq(3).text (record.temperature >> 4).toString()
					color = 'white'
					if dx > 32
						color = 'yellow'
						if dx > 48
							color = 'red'
				$(@dryDataEl).eq(1).css 'background',color
				$(@dryDataEl).eq(3).css 'background',color

			if @curLine isnt record.mode 
				@curLine = record.mode 
				@curLineStartTime = record.time
			if islast
				@showDryParam record 
				@item.drydatas = Drydata.all()
				
	showDryParam:(record)->
		$(@dryDataEl).eq(0).text (record.settingtemperature >> 4).toString()
		$(@dryDataEl).eq(2).text (record.temperature >> 4).toString()
		$(@dryDataEl).eq(7).text parseInt(record.time / 360).toString()+":"+(parseInt(record.time/6) % 60).toString()
		$(@dryDataEl).eq(6).text parseInt((record.time - @curLineStartTime) / 360).toString()+":"+(parseInt((record.time - @curLineStartTime)/6) % 60).toString()
		color = 'green'
		str = ', 正常'
		dx = record.temperature - record.settingtemperature
		if dx < -32
			color = 'yellow'
			str = ', 偏低！'
			if dx < -48
				str = ', 太低！'
				color = 'red'
		if dx > 32
			color = 'yellow'
			str = ', 偏高！'
			if dx > 48
				str = ', 太高！'
				color = 'red'
		$(@dryDataEl).eq(5).css 'background',color
		$(@dryDataEl).eq(5).text "温差 "+(dx//16).toString() + str
		
	# 显示 Drydata 的一个记录
	_showOne:(rec)->
		if rec
			@showDryParam rec
		else
			$(@dryDataEl).eq(0).text '无'
			$(@dryDataEl).eq(2).text '无'
		
	seeIn:(e)->
		@seeX = e.x
		@curDraw?.drawSeeLine @seeX
		
	seeOut:(e)->
		@curDraw?.removeSeeLine @seeX if @seeX
		@_showOne Drydata.last()
		
	seeNext:(e)->
		e.stopPropagation()
		@curDraw?.removeSeeLine @seeX if @seeX
		@seeX = e.offsetX
		x = @curDraw?.drawSeeLine @seeX
		@_showOne Drydata.findByAttribute('time',x)
			
	
module.exports = DryingShows