Spine   = require('spine')

Orderproduct = require('models/orderproduct')
Order = require('models/order')
Goodclass = require('models/goodclass')
Goodlabel = require('models/goodlabel')
Goodeval = require('models/goodeval')
Default = require('models/default')
$       = Spine.$

class myAppraise extends Spine.Controller
	className: 'myappraise'

	elements:
		".tabs":'tabsEl'
		'input[name=upload_baskin]':'baskinEl'
		"#home-menu-2 button": 'btnCare'
		'#producteval ul li a': 'actionEl'
		'#producteval ul li:nth-child(3) a': 'evalEl'
 
	events:
		'click #producteval ul li a': 'actionClick'
		'click .evalnow dl dd a img': 'starClick'
		'mouseover .evalnow dl dd a img': 'enterStar'
		'mouseout .evalnow dl dd a img': 'leaveStar'
		'click .evalnow dl dd input[type=submit]': 'submitEval'
		'click .upload-btn a': 'pickBaskin'
  
	constructor: ->
		super
		@active @change

		@token = $.fn.cookie 'PHPSESSID'
		@star = ""
		@star += "<a><img src='images/star0.png' /></a>" for n in [0..4]

		@orderproduct = $.Deferred()
		@goodclass = $.Deferred()
		@goodlabel = $.Deferred()
		@default = $.Deferred()

		Orderproduct.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText

		Order.bind "refresh",@seekProduct
		Orderproduct.bind "refresh",=> @orderproduct.resolve()
		Goodclass.bind "refresh",=> @goodclass.resolve()
		Goodlabel.bind "refresh",=> @goodlabel.resolve()
		Default.bind "refresh",=> @default.resolve()
		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()
		Goodlabel.fetch()
		Order.fetch()

	render: ->
		@html require("views/appraise")(@item)
		$(@tabsEl).tabs()

		# 查找第一个未评价的产品，如找到则显示评价表框
		for eval in $(@evalEl)
			iseval = $(eval).attr 'data-evalid'
			if iseval is '0'
				$(eval).closest('ul').after require("views/evaluate")(@item)
				break
	
	change: (params) =>
		try
			$.when(@orderproduct,@goodclass,@goodlabel,@default).done( =>
				defaults = Default.first()
				@item = 
					orders:Order.all()
					klass:Goodclass
					labels:Goodlabel.all()
					goods:Orderproduct
					defaults:defaults
				@render()
			)
		catch err
			@log "file: member.main.spending.coffee\nclass: myAppraise\nerror: #{err.message}"
	
	seekProduct:=>
		if Order.count() > 0
			values = []
			i = 0
			for rec in Order.all()
				values[i++] = pro.proid for pro in rec.products when pro.proid not in values
			Orderproduct.append values if i > 0
		else
			@orderproduct.resolve()

	actionClick:(e)->
		switch $(@actionEl).index(e.target) % 3
			when 0
				location.href = "? cmd=ShowProducts&gid="+$(e.target).attr 'data-goodid'
			when 1
				evalid = $(e.target).attr('data-evalid')
				if evalid is '0'
					evalbox = $(".evalnow")
					$(e.target).closest('ul').after if evalbox? then evalbox.remove() else require("views/evaluate")(@item)
				else
					location.href = "? cmd=GoodsEval&eid="+evalid
			when 2
				feelid = $(e.target).attr('data-feelid')
				if feelid is '0'
					location.href = "? cmd=fmBuyFell"
				else
					location.href = "? cmd=GoodsEval&sid="+feelid

	starClick:(e)->
		e.stopPropagation()
		i = $('.evalnow dl dd a img').index $(e.target)
		@star = ""
		@star += "<a><img src='images/star#{if n<=i then 1 else 0}.png' /></a>" for n in [0..4]
		$(".evalnow dl dd:first").html @star

	enterStar:(e)->
		e.stopPropagation()
		i = $('.evalnow dl dd a img').index $(e.target)
		star = ""
		star += "<a><img src='images/star#{if n<=i then 1 else 0}.png' /></a>" for n in [0..4]
		$(".evalnow dl dd:first").html star

	leaveStar:(e)->
		e.stopPropagation()
		$(".evalnow dl dd:first").html @star

	# 澶勭悊"瑕佷笂浼犵殑浜у搧鍥惧儚"鎸夐敭鐐瑰嚮浜嬩欢
	pickBaskin:(e)->
		e.preventDefault()
		e.stopPropagation()
		
		baskinEl = $('input[name=upload_baskin]')
		baskinEl.one 'change', (e1)=>
			e1.stopPropagation()
			files = $(e1.target)[0].files
			if files.length > 0
				img = $("<img src='' />")
				img.insertBefore $(".upload-btn")
				$.fn.uploadFile 'feelimg0',files[0],img,'images/good/feel/'
				n_img = $(".baskin >img").length
				$(".bask_img_num").text "#{n_img}/10"
				$(e.target).attr("disabled",true) if n_img is 10
			
		baskinEl.click()
		

	# 提交评价
	# 根据评价内容在 producteval 表中，创建一个新的记录
	# 把 producteval 表中新创建记录的 id 保存到表 orderproduct 对应记录的 evalid 字段中
	submitEval: (e)->
		e.stopPropagation()
		star = 0
		for img in $('.evalnow dl dd a img')
			star++ if $(img).attr('src').indexOf('star1') > -1
		if star is 0
			alert @item.defaults.translate 'Grade'
			return false

		label = 0
		for inpt in $('.evalnow dl dd span input:checkbox')
			label |= 1<< (parseInt($(inpt).val())-1) if $(inpt).is ':checked'
		if label is 0
			alert @item.defaults.translate 'Label'
			return false

		feel = $('.evalnow dl dd textarea').val()
		feel = $.trim feel
		if feel is null
			alert @item.defaults.translate 'Feelings'
			return false

		proid = $(@actionEl).eq(0).attr 'data-goodid'
		ordergoodid = parseInt $('.evalnow').closest('td').attr 'data-goodid'
		item = 
			producteval:
				proid:proid
				userid:'?userid'
				star:star
				label:label
				useideas:feel
				date:'?time'
			other:[
				table:'orderproduct'
				method:'put'
				data:
					id:ordergoodid
					evalid:'?producteval:id'
			]
			orderproductid:ordergoodid
			token:@token

		param = JSON.stringify(item)
		$.ajax
			url: Goodeval.url # 提交的页面
			data: param
			type: "POST" # 设置请求类型为"POST"，默认为"GET"
			dataType: "json"
			success: (data) =>
				#obj = JSON.parse(data)
				if data.id > -1
					goodeval = {}
					goodeval[item]=data.producteval[item] for item in Goodeval.attributes
					Goodeval.refresh goodeval,clear:false
					for order,i in @item.orders
						for product,j in order.products when parseInt(product.id) is parseInt(data.orderproduct.id)
							order.products[j].evalid = data.id
							order.updateAttributes order.products,ajax:false
							
					#@item.orders.updateAttributes goodeval,ajax: false
					@render()
				else
					switch data.error
						when "Access Denied"
							window.location.reload()
						else
							alert data.error

module.exports = myAppraise