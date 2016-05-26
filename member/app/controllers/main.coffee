Spine   = require('spine')
Manager = require('spine/lib/manager')
Qiye = require('models/qiye')
Navigation = require('models/navigation')
Currency = require('models/currency')
Language = require('models/language')
Default = require('models/default')
Good = require('models/good')
Cart = require('models/cart')
Goodclass = require('models/goodclass')
Goodlabel = require('models/goodlabel')
Goodcare = require('models/goodcare')
User = require('models/user')
Grade = require('models/grade')
Customaccount = require('models/customaccount')
Customgrade = require('models/customgrade')
Custom = require('models/custom')
Person = require('models/person')
Company = require('models/company')
Order = require('models/order')
Province = require('models/province')
Sysnotice = require('models/sysnotice')
Goodconsult = require('models/goodconsult')
Ordercomplain = require('models/ordercomplain')
Complain = require('models/complain')
$       = Spine.$

Headers = require('controllers/main.header')
Footers = require('controllers/main.footer')
Main1    = require('controllers/member.main')
Sidebar = require('controllers/member.sidebar')
loginDialog = require('controllers/loginDialog')

class Main extends Spine.Controller
	className: 'main'
  
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
			
		token = $.fn.cookie 'PHPSESSID'
			
		# 上传图像文件
		$.fn.uploadFile = (key,file,img,path)->
			try
				throw 'File Size > 4M' if file.size > 4*1024*1024
				throw "Invalid File Type #{file.type}" unless file.type in ['image/jpg','image/jpeg','image/png','image/gif']
				formdata = new FormData()
				formdata.append(key, file)
				options = 
					type: 'POST'
					url: '? cmd=Upload&token='+token
					data: formdata
					success:(result) =>
						img.attr 'src',path+token+'/'+result.image
						#alert(result.msg)
					processData: false  # 告诉jQuery不要去处理发送的数据
					contentType: false   # 告诉jQuery不要去设置Content-Type请求头
					dataType:"json"
				$.ajax(options)
			catch error
				alert error
			
		@urlroute = window.location.href #$.getUrlParam('cmd')
		n = @urlroute.indexOf("#")
		@urlroute1 = if n is -1 then	"/members" else @urlroute.substring n+1
		
		@default = $.Deferred()
		@user = $.Deferred()
		Default.bind "refresh",=>@default.resolve()
		User.bind "refresh",=>@user.resolve()

		$.when(@default,@user).done =>
			$.getJSON "? cmd=VerifyStatus&token=#{token}",(result)=>
				if result.status is false
					switch result.error
						when "Not logged!"
							loginDialog().open(default:Default.first(),user:User,sucess:->location.reload()) #replace @urlroute.substring 0,n-1)
						when "Access Denied"
							alert result.error
							window.history.back(-1)
						when "Identity verify is invalid!"
							@navigate  if @urlroute is "/members/updatepassword" then "/members/password" else @urlroute1

		@headers     = new Headers
		@footers     = new Footers
		@sidebar = new Sidebar
		@main    = new Main1
		
		Qiye.fetch()
		Navigation.fetch()
		Language.fetch()
		Default.fetch()
		Cart.fetch()
		Currency.fetch()
		#Good.fetch()
		Goodclass.fetch()
		User.fetch()
		Province.fetch()
		Person.fetch()
		Grade.fetch()
		Customgrade.fetch()
		Order.fetch()
		Custom.fetch()
		Goodlabel.fetch()
		Customaccount.fetch()
		Goodcare.fetch()
		Goodconsult.fetch()
		Sysnotice.fetch()

		Complain.fetch()
		Ordercomplain.fetch()

		@routes
			'/members/order': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.order.active(params)
				@footers.active(params)
			'/members/carefly': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.care.active(params)
				@footers.active(params)
			'/members/complain': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.complain.active(params)
				@footers.active(params)
			'/members/account': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.account.active(params)
				@footers.active(params)
			'/members/balance': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.balance.active(params)
				@footers.active(params)
			'/members/spending': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.spending.active(params)
				@footers.active(params)
			'/members/appraise': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.appraise.active(params)
				@footers.active(params)
			'/members/consult': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.consult.active(params)
				@footers.active(params)
			'/members/message': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.message.active(params)
				@footers.active(params)
			'/members/password': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.password.active(params)
				@footers.active(params)
			'/members/updatepassword': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.updatepassword.active(params)
				@footers.active(params)
			'/members': (params) ->
				@headers.active(params)
				@sidebar.active(params)
				@main.yunrui.active(params)
				@footers.active(params)
    
		divide = $('<div />').addClass('vdivide')
    
		@append @headers,@sidebar, divide, @main,@footers
    
		@navigate @urlroute1

module.exports = Main