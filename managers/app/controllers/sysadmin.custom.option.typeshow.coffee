Spine	= require('spine')

$		= Spine.$

class CustomTypeShows extends Spine.Controller
	className: 'customtypeshows'
  
	constructor: ->
		super
		@active @change
  
	render: ->
		@html require("views/customtype")(@item)
		$("body >header h2").text "经营管理->客户管理->客户信息"
	
	change: (params) =>
		try
			if params.id in [1,2]
				@item = 
					customtype:[{name:'个人用户'},{name:'单位用户'}][params.id]
				@render()
		catch err
			@log "file: sysadmin.main.customtype.option.classshow.coffee\nclass: CustomTypeclassShows\nerror: #{err.message}"

module.exports = CustomTypeShows