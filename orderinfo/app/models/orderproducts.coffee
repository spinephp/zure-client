Spine = require('spine')
require('spine/lib/ajax')

# ����ֵ˰��Ʊģ��
class OrderProducts extends Spine.Model
    @configure 'OrderProducts', 'id',  'longname', 'size','picture', 'price','unit','amount','weight'

    @extend Spine.Model.Ajax

    @url: '? cmd=Product'

module.exports = OrderProducts
