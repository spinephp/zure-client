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

	# �ϴ�ͼ���ļ�
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
				processData: false  # ����jQuery��Ҫȥ�����͵�����
				contentType: false   # ����jQuery��Ҫȥ����Content-Type����ͷ
				dataType:"json"
			$.ajax(options)
		catch error
			alert error

	# �����ƷͼƬ�ı��¼����ϴ�ѡ��Ĳ�ƷͼƬ
	uploadFeel:(e)->
		e.stopPropagation()
		@uploadFile "feelimg"+@token+n,image for image,n in @filefeelEl[0].files when @upimg < 21

	# ����"�ϴ�"��������¼�
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
			url: '? cmd=ProductUse' # �ύ��ҳ��
			data: param
			type: "POST" # ������������Ϊ"POST"��Ĭ��Ϊ"GET"
			dataType: "json"
			beforeSend: -> # ���ñ��ύǰ����
				# new screenClass().lock();
			error: (request)->       # ���ñ��ύ����
				#new screenClass().unlock();
				alert("���ύ�������Ժ�����")
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