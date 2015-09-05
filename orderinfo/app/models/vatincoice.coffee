Spine = require('spine')

# ����ֵ˰��Ʊģ��
class VATInvoice extends Spine.Model
	@configure 'VATInvoice', 'id',  'company', 'address', 'tel', 'duty', 'bank', 'account'

	@extend Spine.Model.Local

	@url: '? cmd=VATInvoice'

module.exports = VATInvoice
