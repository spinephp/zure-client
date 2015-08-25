Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class Drymain extends Spine.Model
	@configure 'Drymain', 'id','starttime','lineno','state'

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=DryMain'

	@fetch: (params) ->
		#condition = [{field:"state",value:"0",operator:"ne"}]
		params or= 
			data:{ filter: @attributes,token: $.fn.cookie 'PHPSESSID'} 
			processData: true
		@ajax().fetch(params)
		true
		
	@getStart:(sucess) ->
		fields = @attributes
		condition = [{field:"state",value:0,operator:"eq"}]
		token =  $.fn.cookie 'PHPSESSID'
		jQuery.getJSON @url,{ cond:condition,filter: fields,token:token },(result) =>
			if result.length
				for o in result
					data = new Drymain o
					data.save ajax:false
					sucess? data
					
	@current:null

	@setCurrent: (item) ->
		@current = item

	@getCurrent: ->
		@setCurrent(@first()) unless @current
		@current

module.exports = Drymain

