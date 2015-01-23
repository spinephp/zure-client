Spine	= require('spine')
Goodclass = require('models/goodclass')
Good = require('models/good')

$		= Spine.$

class GoodEdits extends Spine.Controller
	className: 'goodedits'
  
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
		#Goodclass.bind "refresh",=>@change
  
	render: ->
		@html require("views/fmgood")(@item)
		$("body >header h2").text "经营管理->产品管理->编辑产品"
	
	change: (params) =>
		try
			@item = 
				good:new Good
				goodclasses:Goodclass.all()
			@render()
		catch err
			@log "file: sysadmin.main.good.option.edit.coffee\nclass: GoodEdit\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	# 上传图像文件
	uploadFile:(key,file,img,path)->
		try
			throw 'File Size > 4M' if file.size > 4*1024*1024
			throw "Invalid File Type #{file.type}" unless file.type in ['image/jpg','image/jpeg','image/png','image/gif']
			formdata = new FormData()
			formdata.append(key, file)
			options = 
				type: 'POST'
				url: '? cmd=Upload&token='+@token
				data: formdata
				success:(result) =>
					img.attr 'src',path+result.image
					alert(result.msg)
				processData: false  # 告诉jQuery不要去处理发送的数据
				contentType: false   # 告诉jQuery不要去设置Content-Type请求头
				dataType:"json"
			$.ajax(options)
		catch error
			alert error

	# 处理产品图片改变事件，上传选择的产品图片
	uploadGood:(e)->
		e.stopPropagation()
		@uploadFile 'goodimg'+@token,@filegoodEl[0].files[0],$(@goodimgEl),'images/good/'

	# 处理水印图片改变事件，上传选择的水印图片
	uploadWatermask:(e)->
		e.stopPropagation()
		@uploadFile 'maskimg',@filemaskEl[0].files[0],$(@waterimgEl),'images/'

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
		opt = $(e.target)
		key = $(@formEl).serializeArray()
		item = {product:{}}
		for field in key
			switch field.name[0..1]
				when 'G_'
					item.product[field.name[2..]] = field.value
				else
					item[field.name] = field.value

		img = $(@goodimgEl).attr 'src'
		name = img.replace 'images/good/',''
		item.product['picture'] = name #if name isnt @item.goodclass.picture

		param = JSON.stringify(item)
		$.ajax
			url: "? cmd=Product&token=#{@token}" # 提交的页面
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
					@item.good.updateAttributes data,ajax: false
					Good.trigger "create",@item.good
					@navigate('/goods/',data.id,'show') 
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						when "Validate Code Error!"
							alert "验证码错误，请重新填写。"
							$(".validate").click()
							$(@verifyEl).focus()


module.exports = GoodEdits