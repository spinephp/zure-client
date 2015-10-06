Spine   = require('spine')
Manager = require('spine/lib/manager')
$       = Spine.$

Main    = require('controllers/sysadmin.main')
Sidebar = require('controllers/sysadmin.sidebar')

class Sysadmins extends Spine.Controller
	className: 'sysadmins'
  
	constructor: ->
		super
    
		$.fn.cookie = (c_name)->
			if document.cookie.length>0
				c_start=document.cookie.indexOf(c_name + "=")
				if c_start isnt -1
					c_start=c_start + c_name.length+1 
					c_end=document.cookie.indexOf(";",c_start)
					c_end=document.cookie.length if c_end is -1 
					return unescape(document.cookie.substring(c_start,c_end))
			return ""
			
		$.fn.makeRequestParam = (formEl,item,heads,curtabs)->
			#opt = $(e.target)
			objKeys = Object.keys item
			key = $(formEl).serializeArray()
			item.token = $.fn.cookie "PHPSESSID"
			for field in key
				head = field.name[0..1]
				ckey = field.name[2..]
				cval = $.trim field.value
				if cval isnt ''
					i = $.inArray head,heads
					if i > -1
						item[objKeys[i]][ckey] = cval unless curtabs? or curtabs?[i][ckey] is cval
					else
						item[field.name] = cval
		
		$.fn.ajaxPut = (url,data,success)->
			$.ajax
				url: url #"? cmd=ProductClass&token=#{@token}/"+@item.department.id # 提交的页面
				data: data
				type: "POST" # 设置请求类型为"POST"，默认为"GET"
				dataType: "json"
				beforeSend: (xhr)-> # 设置表单提交前方法
					xhr.setRequestHeader('X-HTTP-Method-Override', 'PUT')
					# new screenClass().lock();
				error: (request)->       # 设置表单提交出错
					#new screenClass().unlock();
					alert("表单提交出错，请稍候再试")
				success: success
				
		$.fn.makeDeleteParam = (formEl,table,success)->
			@url = table.url
			key = $(formEl).serializeArray()
			table.one "beforeDestroy", =>
				table.url = "woo/"+table.url if table.url.indexOf("woo/") is -1
				table.url += "&token="+ $.fn.cookie('PHPSESSID') unless table.url.match /token/
				table.url += "&#{field.name}=#{field.value}" for field in key when not table.url.match "&#{field.name}="

			table.one "ajaxSuccess", (status, xhr) => 
				table.url = @url
				success? status
			
		# 上传图像文件
		$.fn.uploadFile = (key,file,img,path)->
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
						img.attr 'src',path+@token+'/'+result.image
						#alert(result.msg)
					processData: false  # 告诉jQuery不要去处理发送的数据
					contentType: false   # 告诉jQuery不要去设置Content-Type请求头
					dataType:"json"
				$.ajax(options)
			catch error
				alert error

		@sidebar = new Sidebar
		@main    = new Main
    
		@routes
			'/sysadmins/order': (params) -> 
				@sidebar.active(params)
				@main.order.active(params)
			'/sysadmins/contract/:id/edit': (params) -> 
				@sidebar.active(params)
				@main.contractedit.active(params)
			'/sysadmins/good': (params) -> 
				@sidebar.active(params)
				@main.good.active(params)
			'/sysadmins/progress': (params) -> 
				@sidebar.active(params)
				@main.progress.active(params)
			'/sysadmins/drying': (params) -> 
				@sidebar.active(params)
				@main.drying.active(params)
			'/sysadmins/employee': (params) -> 
				@sidebar.active(params)
				@main.employee.active(params)
			'/sysadmins/custom': (params) -> 
				@sidebar.active(params)
				@main.custom.active(params)
			'/sysadmins/login': (params) ->
				@main.login.active(params)
			'/sysadmins': (params) ->
				@sidebar.active(params)
				@main.qiye.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @sidebar, divide, @main
    
		@navigate('/sysadmins/login')
    
module.exports = Sysadmins