Spine	= require('spine')

$		= Spine.$

class VerifyCodes extends Spine.Controller
	className: 'verifycode'
  
	elements:
		'input[name=code]':'verifyEl'
  
	events:
		'click .validate':'verifyCode'
 
	constructor: ->
		super
		@active @change
		Spine.bind "updateverify",->
			$(".validate").click()
			$(@verifyEl).focus()

	render: ->
		@html require("views/fmverifycode")
	
	change: (params) =>
		try
			@render()
		catch err
			@log "file: sysadmin.main.custom.option.add.text.coffee\nclass: CustomAddTexts\nerror: #{err.message}"

	verifyCode:(e)->
		e.stopPropagation()
		$(e.target).attr "src","admin/checkNum_session.php?"+Math.ceil(Math.random()*1000)	
		
module.exports = VerifyCodes