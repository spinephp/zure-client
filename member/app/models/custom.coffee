Spine = require('spine')
Person = require('models/person')
require('spine/lib/ajax')
require('spine/lib/relation')

# 创建企业模型
class Custom extends Spine.Model
	@configure 'Custom', 'id',"type","emailstate","mobilestate","accountstate","integral"
	@extend Spine.Model.Ajax
	#@hasMany 'persons', 'models/Person'
	@url: 'woo/index.php? cmd=Custom'

	@fetch: (params) ->
		fields = @attributes
		condition = [{field:"userid",value:"?userid",operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	accountState:()->
		if @accountstate is 'E' then 'Valid' else 'Invalid'

	picture:->
		Person.first().picture

	username:->
		Person.first().username

	name:->
		Person.first().name

	nick:->
		Person.first().nick

	address:->
		Person.first().address

	sex:->
		Person.first().sex

	email:->
		email = Person.first().email
		tem = email.substr(2,email.indexOf('@')-2)
		email.replace tem,"*****"

	companyid:->
		Person.first().companyid

	mobile:->
		mobile = Person.first().mobile
		tem = mobile.substr(3,5)
		mobile.replace(tem,"*****")

	identitycard:->
		Person.first().identitycard

	lasttime:->
		Person.first().lasttime
	accountsafe:->
		text = [['Low','低'],['generally','一般'],['strong','较强'],['strongest','最强']]
		n = 0
		n++ if @emailstate is 'Y'
		n++ if @mobilestate is 'Y'
		n++ if @accountstate is 'Y'
		{number:n,text:text[n]}
module.exports = Custom
