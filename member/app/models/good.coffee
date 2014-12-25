Spine = require('spine')
require('spine/lib/ajax')
Goodclass = require('models/goodclass')
Goodeval = require('models/goodeval')
# 创建企业模型
class Good extends Spine.Model
	@configure 'Good', 'id',"classid","size","picture","price","amount","status"
	@extend Spine.Model.Ajax
	@url: '? cmd=Product'
	
	names:->
		item = Goodclass.find @classid
		item.names

	kindNames:->
		item = Goodclass.find @classid
		item.kindNames()

	longName:->
		item = Goodclass.find @classid
		item.longName()

	@downPrice:->
		sum = 0
		sum++ for rec in @all() when rec.status is 'D'
		sum

	@salesPromotion:->
		sum = 0
		sum++ for rec in @all() when rec.status is 'P'
		sum

	@newArrive:->
		sum = 0
		sum++ for rec in @all() when rec.status is 'N'
		sum

	downPrice:->
		Good.downPrice()

	salesPromotion:->
		Good.salesPromotion()

	newArrive:->
		Good.newArrive()

module.exports = Good
