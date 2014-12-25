Spine = require('spine')
Person = require('models/person')
require('spine/lib/ajax')
require('spine/lib/relation')

# ������ҵģ��
class Company extends Spine.Model
	@configure 'Company', 'id',"name","address","bank","account","email","www","tel","fax","postcard","duty"
	@extend Spine.Model.Ajax
	#@hasMany 'persons', 'models/Person'
	@url: '? cmd=Company'


module.exports = Company
