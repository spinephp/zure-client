Spine = require('spine')
require('spine/lib/ajax')

# 创增值税发票模型
class OrderProducts extends Spine.Model
    @configure 'OrderProducts', 'id',  'longnames', 'size','picture', 'price','unit','amount','weight'

    @extend Spine.Model.Ajax

    @url: 'woo/index.php? cmd=Product'

module.exports = OrderProducts
