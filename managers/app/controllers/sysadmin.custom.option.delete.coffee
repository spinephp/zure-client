Spine	= require('spine')
Custom = require('models/custom')
Person = require('models/person')

$		= Spine.$

class CustomDeletes extends Spine.Controller
	className: 'customdeletes'
  
	elements:
		'form':'formEl'
  
	events:
		'click .validate':'verifyCode'
		'click input[type=submit]': 'option'
  
	constructor: ->
		super
		@active @change
		@custom = $.Deferred()
		@url = Custom.url
		Custom.bind "refresh",=>@custom.resolve()
  
	render: ->
		@html require("views/customdelete")(@item)
		$("body >header h2").text "经营管理->客户管理->删除客户"
	
	change: (params) =>
		try
			$.when( @custom).done =>
				if Custom.exists params.id
					custom = Custom.find params.id
					@item = 
						custom:custom
						person:Person.find custom.userid
					@render()
		catch err
			@log "file: sysadmin.main.custom.option.delete.coffee\nclass: CustomDeletes\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	

	option: (e)=>
		e.stopPropagation()
		e.preventDefault()
		$.fn.makeDeleteParam @formEl,Custom,(status)->
			@item.person.destroy(ajax:false) if status.destroyed

		@item.custom.destroy() if confirm("删除客户将删除与该客户相关联的所有数据，如账号，订单等等，请谨慎操作！\n确实要删除客户 #{@item.custom.getName()} 吗?")

module.exports = CustomDeletes