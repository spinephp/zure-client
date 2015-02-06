Spine   = require('spine')
Order = require('models/order')
Good = require('models/good')
Goodclass = require('models/goodclass')
Default = require('models/default')
$       = Spine.$

class Middles extends Spine.Controller
	className: 'middles'
  
	elements:
		'form':'formEl'
		'input[name=upload_feel]':'filefeelEl'
		'input[name=upload_feel]+button b':'upimgsEl'
  
	events:
		'change input[name=upload_feel]':'uploadFeel'
		'click input[name=upload_feel]+button':'pickfeelimg'
		'click input[type=submit]':'publish'

	constructor: ->
		super
		@active @change
		@token = $.fn.cookie('PHPSESSID')
		@upimg = 0

		@good = $.Deferred()
		@goodclass = $.Deferred()
		@default = $.Deferred()
		Good.bind "refresh",=>@good.resolve()
		Goodclass.bind "refresh",=>@goodclass.resolve()
		Default.bind "refresh",=>@default.resolve() if Default.count() > 0
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
		
	render: =>
		@html require('views/middle')(@item)

	change: (item) =>
		try
			$.when(@good,@goodclass,@default).done =>
				@item = 
					orders:Order.all()
					goods:Good
					klass:Goodclass
					default:Default.first()
				@render()
		catch err
			console.log err.message

	# 上传图像文件
	uploadFile:(key,file)->
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
					@upimg++
					$(@upimgsEl).html @upimg
				processData: false  # 告诉jQuery不要去处理发送的数据
				contentType: false   # 告诉jQuery不要去设置Content-Type请求头
				dataType:"json"
			$.ajax(options)
		catch error
			alert error

	# 处理产品图片改变事件，上传选择的产品图片
	uploadFeel:(e)->
		e.stopPropagation()
		@uploadFile "feelimg"+@token+n,image for image,n in @filefeelEl[0].files when @upimg < 21

	# 处理"上传"按键点击事件
	pickfeelimg:(e)->
		e.preventDefault()
		e.stopPropagation()
		$(@filefeelEl).click()

	publish:(e)->
		e.preventDefault()
		e.stopPropagation()
		return false if @upimg < 3 or @upimg > 20
		key = $(@formEl).serializeArray()
		pos = key[0].value.indexOf '|'
		ordergoodid = key[0].value[pos+1..]
		key[0].value = key[0].value[0...pos]
		item = {productuse:{}}
		for field in key
			return false unless field.value?
			switch field.name[0..1]
				when 'F_'
					item.productuse[field.name[2..]] = field.value
				else
					item[field.name] = field.value

		item.productuse['userid'] = '?userid'
		item.productuse['date'] = '?time'
		item.uploadimages = @upimg
		item.other = [
			table:'orderproduct'
			method:'put'
			data:
				id:ordergoodid
				feelid:'?productuse:id'
		]
		item.token = @token

		param = JSON.stringify(item)
		$.ajax
			url: '? cmd=ProductUse' # 提交的页面
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
					for order,i in @item.orders
						for product,j in order.products when parseInt(product.id) is parseInt(data.orderproduct.id)
							order.products[j].feelid = data.id
							order.updateAttributes order.products,ajax:false
					@render()
				else
					switch data.error
						when "Access Denied"
							window.location.reload()


module.exports = Middles