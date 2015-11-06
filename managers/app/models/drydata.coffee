Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class Drydata extends Spine.Model
	@configure 'Drydata', 'id','mainid','time','settingtemperature','temperature','mode'

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=DryData'

	@fetch: (params) ->
		@scope = 'woo/'
		condition = [{field:"state",value:"0",operator:"eq"}]
		params or= 
			data:{ filter: @attributes,cond:condition,token: $.fn.cookie 'PHPSESSID'} 
			processData: true
		@ajax().fetch(params)
		true
		
	@getNew:(mainid,sucess) ->
		fields = @attributes
		condition = [{field:"mainid",value:mainid,operator:"eq"},{field:"id",value:Drydata.last()?.id or 0,operator:"gt"}]
		token =  $.fn.cookie 'PHPSESSID'
		jQuery.getJSON @url,{ cond:condition,filter: fields,token:token },(result) =>
			if result.length
				result.sort (a,b)->
					return if a.id>b.id then 1 else -1
				
				for o,i in result when not Drydata.exists o.id
					data = new Drydata o
					data.save(ajax:false)
					sucess? data,i is result.length-1

module.exports = Drydata
