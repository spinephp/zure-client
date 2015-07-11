Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class Drydata extends Spine.Model
	@configure 'Drydata', 'id','mainid','time','settingtemperature','temperature','mode'

	@extend Spine.Model.Ajax

	@url: '? cmd=Drydata'

	@fetch: (params) ->
		condition = [{field:"state",value:"0",operator:"eq"}]
		params or= 
			data:{ filter: @attributes,cond:condition,token: $.fn.cookie 'PHPSESSID'} 
			processData: true
		@ajax().fetch(params)
		true

module.exports = Drydata
