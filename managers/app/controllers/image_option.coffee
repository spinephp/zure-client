Spine = require('spine')

class ImageOption extends Spine.Controller
	className: 'imageoption'
  
	elements:
		"button":"buttonEl"
		'form':'formEl'
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
		'>img':"imgEl"
		'.watermode img':"waterimgEl"
		'input[name=upload_image]':'fileImgEl'
		'input[name=upload_mask]':'filemaskEl'
		'input[name=code]':'verifyEl'
		'.waterType':'watermaskEl'
		'.watermode':'watermodeEl'
  
	events:
		'change input[name=upload_image]':'uploadImg'
		'change input[name=upload_mask]':'uploadWatermask'
		'click input[name=upload_image]+p button':'pickImg'
		'click .watermode p button':'pickmaskImg'
		'click input[name=watermask]': 'watermaskClick'
		'click input[name=watersel]': 'waterselClick'
		
	constructor:(imgClass,imgPath,imgWidth) ->
		@imgClass = imgClass
		@imgPath = imgPath
		@imgWidth = imgWidth or "98%"
		#@picture = null
		@token = $.fn.cookie('PHPSESSID')
		@active @change
		@imagechange = $.Deferred()
		Spine.bind "image:change",(picture)=>
			@picture = picture
			@imagechange.resolve()
		super
 
	render: ->
		@html require("views/img_option")(@item)
	
	change: (params) =>
		try
			$.when(@imagechange).done =>
				@item = 
					imgclass:@imgClass
					imgpath:@imgPath
					picture:@picture
				@render()
			$(@imgEl).css "width",@imgWidth
		catch err
			@log "file: sysadmin.main.good.option.classedit.coffee\nclass: GoodclassEdit\nerror: #{err.message}"

	# 处理产品图片改变事件，上传选择的产品图片
	uploadImg:(e)=>
		e.stopPropagation()
		$.fn.uploadFile @imgClass+@token,@fileImgEl[0].files[0],$(@imgEl),'images/'+@imgPath+'/'

	# 处理水印图片改变事件，上传选择的水印图片
	uploadWatermask:(e)->
		e.stopPropagation()
		$.fn.uploadFile 'maskimg',@filemaskEl[0].files[0],$(@waterimgEl),'images/'

	# 处理"要上传的产品图像"按键点击事件
	pickImg:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@fileImgEl).click()

	# 处理"要上传的水印图像"按键点击事件
	pickmaskImg:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@filemaskEl).click()
	
	# 处理"添加水印"检查框点击事件，根据检查框选中状态显示或隐藏水印功能界面
	watermaskClick:(e)->
		e.stopPropagation()
		display = if $(e.target).is(':checked') then 'block' else 'none'
		$(@watermaskEl).css 'display',display
		
	# 处理水印类型单选框点击事件，根据选中的单选框显示文本或图形水印功能界面
	waterselClick:(e)->
		e.stopPropagation()
		$(@watermodeEl)
			.css('display','none')
			.eq($(e.target).val())
			.css 'display','block'
			
	getImage:->
		@imgEl
		
module.exports = ImageOption