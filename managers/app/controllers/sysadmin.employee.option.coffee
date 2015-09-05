Spine   = require('spine')

$       = Spine.$

ShowDepartments = require('controllers/sysadmin.employee.option.departmentshow')
NewDepartments = require('controllers/sysadmin.employee.option.departmentadd')
EditDepartments = require('controllers/sysadmin.employee.option.departmentedit')
DeleteDepartments = require('controllers/sysadmin.employee.option.departmentdelete')

ShowEmployees = require('controllers/sysadmin.employee.option.show')
NewEmployees = require('controllers/sysadmin.employee.option.add')
EditEmployees = require('controllers/sysadmin.employee.option.edit')
DeleteEmployees = require('controllers/sysadmin.employee.option.delete')

class EmployeeOption extends Spine.Stack
	className: 'employeeoption stack'
	
	controllers:
		departmentshow: ShowDepartments
		departmentadd: NewDepartments
		departmentedit: EditDepartments
		departmentdelete: DeleteDepartments
		employeeshow: ShowEmployees
		employeeadd: NewEmployees
		employeeedit: EditEmployees
		employeedelete: DeleteEmployees
	
module.exports = EmployeeOption