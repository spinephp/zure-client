Spine = require('spine')
require('spine/lib/ajax')

# ����ֵ˰��Ʊģ��
class OrderProducts extends Spine.Model
    @configure 'OrderProducts', 'id',  'longnames', 'size','picture', 'price','unit','amount','weight'

    @extend Spine.Model.Ajax

    @url: 'woo/index.php? cmd=Product'

module.exports = OrderProducts
