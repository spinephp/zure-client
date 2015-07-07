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