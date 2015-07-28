Spine	= require('spine')
Drymain = require('models/drymain')
Drydata = require('models/drydata')
draw = require('controllers/draw')

$		= Spine.$

class DryingDeletes extends Spine.Controller
	className: 'dryingdeletes'
  
	elements:
		".drylines":"canvasEl" # ????
		".scale":"scaleEl"
		".scrollbar-track-x":"scrollTrackEl"
		".scrollbar-thumb-x":"scrollThumbEl"
		'form':'formEl'
  
	events:
		'change select[name=scale]':'scaleEdited'
		'click .scrollbar-left':'ckScrollLeft'
		'click .scrollbar-right':'ckScrollRight'
		"click .scrollbar-track-x":"ckScrollTrack"
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@drymain = $.Deferred()
		@drydata = $.Deferred()
		Drymain.bind "refresh",=>@drymain.resolve()
		Drydata.bind "refresh",=>@drydata.resolve()
		@url = Drymain.url

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
		@html require("views/drydelete")(@item)
		$("body >header h2").text "劳资管理->员工管理->删除员工"
		@curDraw = new draw @canvasEl
		@curDraw.drawTemperature(@item.drydatas)
		$(@scrollTrackEl).width $(@canvasEl).parent().width() - 50
		@maxScrollerThumb = $(@scrollTrackEl).width() - 20
		@setScrollBar()
	
	change: (params) =>
		try
			$.when(@drymain,@drydata).done =>
				if Drymain.exists params.id
					drymain = Drymain.find params.id
					datas = Drydata.findByAttribute 'mainid',params.id
					@item = 
						drymains:drymain
						drydatas:datas or []
					@render()
		catch err
			@log "file: sysadmin.drying.option.show.coffee\nclass: DryingShows\nerror: #{err.message}"
			
	setScrollBar:=>
		@lasttime = Drydata?.last()?.time or 0
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

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		key = $(@formEl).serializeArray()
		Drymain.one "beforeDestroy", =>
			Drymain.url = "woo/index.php"+Drymain.url if Drymain.url.indexOf("woo/index.phjp") is -1
			Drymain.url += "&token="+ $.fn.cookie('PHPSESSID') unless Drymain.url.match /token/
			Drymain.url += "&#{field.name}=#{field.value}" for field in key when not Drymain.url.match "&#{field.name}="

		Drymain.one "ajaxSuccess", (status, xhr) => 
			Drymain.url = @url
			items = Drydatas.findByAttribute 'mainid',@item.drymains.id
			items.destroy ajax:false
		@item.drymains.destroy() if confirm("确实要删除 #{@item.drymains.starttime} 的干燥记录吗?")

module.exports = DryingDeletes