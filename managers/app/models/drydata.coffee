Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class Drydata extends Spine.Model
	@configure 'Drydata', 'id','mainid','time','settingtemperature','temperature','mode'

	@extend Spine.Model.Ajax

	@url: '? cmd=DryData'

	@fetch: (params) ->
		condition = [{field:"state",value:"0",operator:"eq"}]
		params or= 
			data:{ filter: @attributes,cond:condition,token: $.fn.cookie 'PHPSESSID'} 
			processData: true
		@ajax().fetch(params)
		true
		
	@getNew:(mainid,sucess) ->
		fields = @attributes
		condition = [{field:"mainid",value:mainid,operator:"eq"},{field:"id",value:Drydata.last().id,operator:"lt"}]
		token =  $.fn.cookie 'PHPSESSID'
		jQuery.getJSON Drydata.url,{ cond:condition,filter: fields,token:token },(result) =>
			if result.length
				for o in result
					data = new Drydata o
					#sucess? data

module.exports = Drydata
