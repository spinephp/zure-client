Spine = require('spine')
require('spine/lib/ajax')
Company = require('models/company')

# 创建企业模型
class Person extends Spine.Model
	@configure 'Person', 'id',"username","name","sex","mobile","tel","email","qq","county","address","picture","identitycard","registertime","companyid"


	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=Person'

	@notFound:(id)->
		fields = @attributes
		condition = [{field:"id",value:id,operator:"eq"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			console.log data[0].id
			if parseInt( data[0].id) > -1
				@refresh data[0]
	@append:(ids)->
		fields = @attributes
		condition = [{field:"id",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false if data.length > 0

	companyName:->
		item = Company.find @companyid
		item.name

module.exports = Person
