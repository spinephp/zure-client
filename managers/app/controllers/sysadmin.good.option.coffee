Spine   = require('spine')

$       = Spine.$

ShowGoodClasses = require('controllers/sysadmin.good.option.classshow')
NewGoodclasses = require('controllers/sysadmin.good.option.classadd')
EditGoodclasses = require('controllers/sysadmin.good.option.classedit')
DeleteGoodclasses = require('controllers/sysadmin.good.option.classdelete')

ShowGoods = require('controllers/sysadmin.good.option.show')
NewGoods = require('controllers/sysadmin.good.option.add')
EditGoods = require('controllers/sysadmin.good.option.edit')
DeleteGoods = require('controllers/sysadmin.good.option.delete')

class GoodOption extends Spine.Stack
	className: 'goodoption stack'
	
	controllers:
		classshow: ShowGoodClasses
		classadd: NewGoodclasses
		classedit: EditGoodclasses
		goodshow: ShowGoods
		goodadd: NewGoods
		goodedit: EditGoods
		gooddelete: DeleteGoods
		classdelete: DeleteGoodclasses
	
module.exports = GoodOption