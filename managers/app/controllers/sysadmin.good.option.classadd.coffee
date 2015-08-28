Spine	= require('spine')
Goodclass = require('models/goodclass')

$		= Spine.$

class GoodclassAdds extends Spine.Controller
	className: 'goodclassadds'
  
	elements:
		"button":"buttonEl"
		'form':'formEl'
		'tr td input[type=checkbox]':'selectedEl'
		'form div:first-child p:nth-child(2) select':"addressEl"
		'form >div:eq(-1) >img':"goodimgEl"
		'.watermode img':"waterimgEl"
		'input[name=upload_good]':'filegoodEl'
		'input[name=upload_mask]':'filemaskEl'
		'input[name=code]':'verifyEl'
		'.waterType':'watermaskEl'
		'.watermode':'watermodeEl'
  
	events:
		'click .validate':'verifyCode'
		'change input[name=upload_good]':'uploadGood'
		'change input[name=upload_mask]':'uploadWatermask'
		'click input[name=upload_good]+p button':'pickgoodimg'
		'click .watermode p button':'pickmaskimg'
		'click input[name=watermask]': 'watermaskClick'
		'click input[name=watersel]': 'waterselClick'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@token = $.fn.cookie('PHPSESSID')
		@active @change
		Goodclass.bind "refresh",=>@change
  
	render: ->
		@html require("views/fmgoodclass")(@item)
		$("body >header h2").text "经营管理->产品管理->添加产品类"
	
	change: (params) =>
		try
			@item = 
				goodclass:new Goodclass
				goodclasses:Goodclass.all()
			@render()
		catch err
			@log "file: sysadmin.main.good.option.classedit.coffee\nclass: GoodclassEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	# 处理产品图片改变事件，上传选择的产品图片
	uploadGood:(e)->
		e.stopPropagation()
		$.fn.uploadFile 'goodimg'+@token,@filegoodEl[0].files[0],$(@goodimgEl),'images/good/'

	# 处理水印图片改变事件，上传选择的水印图片
	uploadWatermask:(e)->
		e.stopPropagation()
		$.fn.uploadFile 'maskimg',@filemaskEl[0].files[0],$(@waterimgEl),'images/'

	# 处理"要上传的产品图像"按键点击事件
	pickgoodimg:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@filegoodEl).click()

	# 处理"要上传的水印图像"按键点击事件
	pickmaskimg:(e)->
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

	option: (e)->
		e.preventDefault()
		item = $.fn.makeRequestParam e,@formEl,['productclass'],['G_']

		img = $(@goodimgEl).attr 'src'
		name = img.replace 'images/good/',''
		name = 'noimg.png' if name is ''
		item.productclass['picture'] = name #if name isnt @item.goodclass.picture

		param = JSON.stringify(item)
		$.ajax
			url: "? cmd=ProductClass" # 提交的页面
			data: param
			type: "POST" # 设置请求类型为"POST"，默认为"GET"
			dataType: "json"
			beforeSend: -> # 设置表单提交前方法
				# new screenClass().lock();
			error: (request)->       # 设置表单提交出错
				#new screenClass().unlock();
				alert("表单提交出错，请稍候再试")
			success: (data) =>
				#obj = JSON.parse(data)
				if data.id > -1
					alert "数据保存成功！"
					@item.goodclass.updateAttributes data.productclass[0],ajax: false
					Goodclass.trigger "create",@item.goodclass
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							$(".validate").click()
							$(@verifyEl).focus()


module.exports = GoodclassAdds