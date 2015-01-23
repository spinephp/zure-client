Spine = require('spine')
require('spine/lib/ajax')
Company = require('models/company')

# ������ҵģ��
class OrderPerson extends Spine.Model
	@configure 'OrderPerson', 'id',"name","companyid"


	@extend Spine.Model.Ajax

	@url: '? cmd=Person'
	
	companyName:->
		item = Company.find @companyid
		item.name

module.exports = OrderPerson
