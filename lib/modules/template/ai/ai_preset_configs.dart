import '../template_models.dart';

/// Field Configuration
class FieldConfig {
  final String name;
  final String label;
  final FieldType type;
  final bool required;
  final List<String>? options;
  final String? placeholder;
  final Map<String, dynamic> validation;

  const FieldConfig(
    this.name,
    this.label,
    this.type, {
    this.required = false,
    this.options,
    this.placeholder,
    this.validation = const {},
  });

  TemplateField toTemplateField(int order) => TemplateField(
        id: 'field_${DateTime.now().millisecondsSinceEpoch}_$order',
        name: name,
        label: label,
        type: type,
        required: required,
        order: order,
        placeholder: placeholder,
        options: options,
        validation: validation,
      );
}

/// Approval Step Configuration
class ApprovalStepConfig {
  final String name;
  final List<String> approvers;
  final bool requireAll;
  final String? condition;

  const ApprovalStepConfig(
    this.name,
    this.approvers, {
    this.requireAll = false,
    this.condition,
  });

  ApprovalStep toApprovalStep(int level) => ApprovalStep(
        id: 'step_${DateTime.now().millisecondsSinceEpoch}_$level',
        level: level,
        name: name,
        approvers: approvers,
        requireAll: requireAll,
        condition: condition,
      );
}

/// AI Preset Configuration
class AiPresetConfig {
  final List<String> keywords;
  final String name;
  final String description;
  final List<FieldConfig> fields;
  final List<ApprovalStepConfig> approvalSteps;
  final int priority;

  const AiPresetConfig({
    required this.keywords,
    required this.name,
    required this.description,
    required this.fields,
    required this.approvalSteps,
    this.priority = 0,
  });
}

/// 15 AI Preset Scenarios (All in English)
final List<AiPresetConfig> aiPresetConfigs = [
  // === High Frequency (Cover 80% usage) ===

  // 1. Leave Request
  AiPresetConfig(
    keywords: [
      'leave',
      'vacation',
      '请假',
      '休假',
      '年假',
      '病假',
      '事假',
      '调休',
      '婚假',
      '产假'
    ],
    name: 'Leave Request',
    description:
        'Employee leave request workflow supporting multiple leave types',
    priority: 100,
    fields: [
      const FieldConfig('leave_type', 'Leave Type', FieldType.dropdown,
          required: true,
          options: [
            'Annual Leave',
            'Sick Leave',
            'Personal Leave',
            'Compensatory Leave',
            'Marriage Leave',
            'Maternity Leave',
            'Paternity Leave',
            'Bereavement Leave'
          ]),
      const FieldConfig('start_date', 'Start Date', FieldType.date,
          required: true),
      const FieldConfig('end_date', 'End Date', FieldType.date, required: true),
      const FieldConfig('days', 'Leave Days', FieldType.number, required: true),
      const FieldConfig('reason', 'Leave Reason', FieldType.multiline,
          required: true,
          placeholder: 'Please describe your leave reason in detail'),
      const FieldConfig('contact', 'Emergency Contact', FieldType.text,
          placeholder: 'Phone or email'),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Manager Approval', []),
      const ApprovalStepConfig('HR Approval', [], condition: 'days > 3'),
    ],
  ),

  // 2. Expense Reimbursement
  AiPresetConfig(
    keywords: ['expense', 'reimbursement', '报销', '费用', '发票', '差旅费'],
    name: 'Expense Reimbursement',
    description: 'Travel and daily expense reimbursement workflow',
    priority: 95,
    fields: [
      const FieldConfig('category', 'Expense Category', FieldType.dropdown,
          required: true,
          options: [
            'Travel',
            'Meals',
            'Office Supplies',
            'Transportation',
            'Communication',
            'Entertainment',
            'Other'
          ]),
      const FieldConfig('amount', 'Reimbursement Amount', FieldType.currency,
          required: true),
      const FieldConfig('date', 'Expense Date', FieldType.date, required: true),
      const FieldConfig('invoice', 'Invoice Attachment', FieldType.file),
      const FieldConfig(
          'description', 'Expense Description', FieldType.multiline,
          required: true,
          placeholder: 'Please explain the reason for this expense'),
      const FieldConfig('project', 'Related Project', FieldType.text,
          placeholder: 'If applicable, enter project name'),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Manager Approval', []),
      const ApprovalStepConfig('Finance Approval', []),
    ],
  ),

  // 3. Procurement Request
  AiPresetConfig(
    keywords: ['procurement', 'purchase', '采购', '买东西', '购置'],
    name: 'Procurement Request',
    description: 'Office supplies and equipment procurement workflow',
    priority: 90,
    fields: [
      const FieldConfig('item_name', 'Item Name', FieldType.text,
          required: true, placeholder: 'e.g., Laptop, Office Chair'),
      const FieldConfig('category', 'Item Category', FieldType.dropdown,
          required: true,
          options: [
            'Office Equipment',
            'Office Supplies',
            'Software License',
            'Service',
            'Raw Materials',
            'Other'
          ]),
      const FieldConfig('quantity', 'Quantity', FieldType.number,
          required: true),
      const FieldConfig('unit_price', 'Unit Price Budget', FieldType.currency,
          required: true),
      const FieldConfig('total_amount', 'Total Amount', FieldType.currency,
          required: true),
      const FieldConfig('supplier', 'Preferred Supplier', FieldType.text,
          placeholder: 'If you have a preferred supplier'),
      const FieldConfig('reason', 'Procurement Reason', FieldType.multiline,
          required: true,
          placeholder: 'Explain the necessity and purpose of this purchase'),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Department Manager Approval', []),
      const ApprovalStepConfig('Finance Approval', []),
      const ApprovalStepConfig('CEO Approval', [],
          condition: 'total_amount > 5000'),
    ],
  ),

  // 4. Business Trip Request
  AiPresetConfig(
    keywords: ['business trip', 'travel', '出差', '差旅'],
    name: 'Business Trip Request',
    description: 'Employee business trip request and budget approval',
    priority: 85,
    fields: [
      const FieldConfig('destination', 'Destination', FieldType.text,
          required: true, placeholder: 'e.g., Beijing, Shanghai, Shenzhen'),
      const FieldConfig('purpose', 'Trip Purpose', FieldType.multiline,
          required: true,
          placeholder: 'Describe the specific purpose and tasks of this trip'),
      const FieldConfig('start_date', 'Departure Date', FieldType.date,
          required: true),
      const FieldConfig('end_date', 'Return Date', FieldType.date,
          required: true),
      const FieldConfig('days', 'Trip Duration (Days)', FieldType.number,
          required: true),
      const FieldConfig('budget', 'Budget', FieldType.currency,
          required: true, placeholder: 'Estimated total cost'),
      const FieldConfig('transport', 'Transportation', FieldType.dropdown,
          options: ['Flight', 'High-speed Rail', 'Train', 'Bus', 'Self-drive']),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Manager Approval', []),
      const ApprovalStepConfig('Director Approval', [],
          condition: 'budget > 5000'),
    ],
  ),

  // 5. Overtime Request
  AiPresetConfig(
    keywords: ['overtime', '加班'],
    name: 'Overtime Request',
    description: 'Employee overtime request and compensation approval',
    priority: 80,
    fields: [
      const FieldConfig('date', 'Overtime Date', FieldType.date,
          required: true),
      const FieldConfig('start_time', 'Start Time', FieldType.text,
          required: true, placeholder: 'e.g., 18:00'),
      const FieldConfig('end_time', 'End Time', FieldType.text,
          required: true, placeholder: 'e.g., 21:00'),
      const FieldConfig('hours', 'Overtime Hours', FieldType.number,
          required: true),
      const FieldConfig('reason', 'Overtime Reason', FieldType.multiline,
          required: true,
          placeholder: 'Explain the specific reason for overtime'),
      const FieldConfig('project', 'Related Project/Task', FieldType.text),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Manager Approval', []),
    ],
  ),

  // === Medium Frequency ===

  // 6. Payment Request
  AiPresetConfig(
    keywords: ['payment', '打款', '转账', '付款'],
    name: 'Payment Request',
    description: 'External payment and transfer request workflow',
    priority: 75,
    fields: [
      const FieldConfig('payee', 'Payee Name', FieldType.text, required: true),
      const FieldConfig('amount', 'Payment Amount', FieldType.currency,
          required: true),
      const FieldConfig('bank_account', 'Bank Account', FieldType.text),
      const FieldConfig('bank_name', 'Bank Name', FieldType.text),
      const FieldConfig('purpose', 'Payment Purpose', FieldType.multiline,
          required: true),
      const FieldConfig('contract', 'Related Contract', FieldType.file),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Department Manager Approval', []),
      const ApprovalStepConfig('Finance Approval', []),
      const ApprovalStepConfig('CEO Approval', [], condition: 'amount > 10000'),
    ],
  ),

  // 7. Budget Approval
  AiPresetConfig(
    keywords: ['budget', '预算'],
    name: 'Budget Approval',
    description: 'Department budget request and adjustment workflow',
    priority: 70,
    fields: [
      const FieldConfig('department', 'Department', FieldType.text,
          required: true),
      const FieldConfig('budget_type', 'Budget Type', FieldType.dropdown,
          required: true,
          options: [
            'Annual Budget',
            'Quarterly Budget',
            'Project Budget',
            'Temporary Budget'
          ]),
      const FieldConfig('category', 'Budget Category', FieldType.dropdown,
          options: [
            'Personnel',
            'Marketing',
            'R&D',
            'Administration',
            'Other'
          ]),
      const FieldConfig('amount', 'Budget Amount', FieldType.currency,
          required: true),
      const FieldConfig('period', 'Budget Period', FieldType.text,
          placeholder: 'e.g., 2024 Q1'),
      const FieldConfig(
          'justification', 'Budget Justification', FieldType.multiline,
          required: true, placeholder: 'Detail your budget needs and usage'),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Director Approval', []),
      const ApprovalStepConfig('Finance Approval', []),
      const ApprovalStepConfig('CEO Approval', []),
    ],
  ),

  // 8. Contract Approval
  AiPresetConfig(
    keywords: ['contract', '协议', '合同'],
    name: 'Contract Approval',
    description: 'Various contracts and agreements approval workflow',
    priority: 65,
    fields: [
      const FieldConfig('contract_name', 'Contract Name', FieldType.text,
          required: true),
      const FieldConfig('contract_type', 'Contract Type', FieldType.dropdown,
          required: true,
          options: [
            'Procurement',
            'Sales',
            'Service',
            'Employment',
            'NDA',
            'Other'
          ]),
      const FieldConfig('counterparty', 'Counterparty', FieldType.text,
          required: true),
      const FieldConfig('amount', 'Contract Amount', FieldType.currency,
          required: true),
      const FieldConfig('contract_file', 'Contract Document', FieldType.file,
          required: true),
      const FieldConfig('payment_terms', 'Payment Terms', FieldType.multiline),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Department Manager Approval', []),
      const ApprovalStepConfig('Legal Approval', []),
      const ApprovalStepConfig('Finance Approval', []),
      const ApprovalStepConfig('CEO Approval', []),
    ],
  ),

  // 9. Vehicle Request
  AiPresetConfig(
    keywords: ['vehicle', 'car', '用车', '派车'],
    name: 'Vehicle Request',
    description: 'Company vehicle usage request workflow',
    priority: 60,
    fields: [
      const FieldConfig('destination', 'Destination', FieldType.text,
          required: true),
      const FieldConfig('purpose', 'Purpose', FieldType.multiline,
          required: true),
      const FieldConfig('start_date', 'Departure Date', FieldType.date,
          required: true),
      const FieldConfig('end_date', 'Return Date', FieldType.date,
          required: true),
      const FieldConfig('passengers', 'Number of Passengers', FieldType.number,
          required: true),
      const FieldConfig('vehicle_type', 'Vehicle Type', FieldType.dropdown,
          options: ['Sedan', 'Minivan', 'Van', 'Truck', 'Any']),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Department Manager Approval', []),
      const ApprovalStepConfig('Admin Approval', []),
    ],
  ),

  // 10. Asset Request
  AiPresetConfig(
    keywords: ['asset', 'borrow', '领用', '借用'],
    name: 'Asset Request',
    description: 'Office supplies and asset borrowing workflow',
    priority: 55,
    fields: [
      const FieldConfig('item_name', 'Item Name', FieldType.text,
          required: true),
      const FieldConfig('category', 'Category', FieldType.dropdown, options: [
        'Office Supplies',
        'Electronics',
        'Furniture',
        'Tools',
        'Other'
      ]),
      const FieldConfig('quantity', 'Quantity', FieldType.number,
          required: true),
      const FieldConfig('purpose', 'Purpose', FieldType.multiline,
          required: true),
      const FieldConfig('return_date', 'Expected Return Date', FieldType.date),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Department Manager Approval', []),
      const ApprovalStepConfig('Admin Approval', []),
    ],
  ),

  // === Low Frequency ===

  // 11. Onboarding
  AiPresetConfig(
    keywords: ['onboarding', '入职', '新员工'],
    name: 'Employee Onboarding',
    description: 'New employee onboarding approval workflow',
    priority: 50,
    fields: [
      const FieldConfig('employee_name', 'Employee Name', FieldType.text,
          required: true),
      const FieldConfig('position', 'Position', FieldType.text, required: true),
      const FieldConfig('department', 'Department', FieldType.text,
          required: true),
      const FieldConfig('start_date', 'Start Date', FieldType.date,
          required: true),
      const FieldConfig('salary', 'Salary', FieldType.currency),
      const FieldConfig('resume', 'Resume', FieldType.file, required: true),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Department Manager Approval', []),
      const ApprovalStepConfig('HR Approval', []),
      const ApprovalStepConfig('CEO Approval', []),
    ],
  ),

  // 12. Offboarding
  AiPresetConfig(
    keywords: ['offboarding', 'resignation', '离职', '辞职'],
    name: 'Employee Offboarding',
    description: 'Employee resignation and handover workflow',
    priority: 45,
    fields: [
      const FieldConfig('employee_name', 'Employee Name', FieldType.text,
          required: true),
      const FieldConfig('department', 'Department', FieldType.text,
          required: true),
      const FieldConfig('last_working_day', 'Last Working Day', FieldType.date,
          required: true),
      const FieldConfig('reason', 'Reason', FieldType.dropdown,
          required: true,
          options: [
            'Personal',
            'Family',
            'Career Growth',
            'Compensation',
            'Work Environment',
            'Other'
          ]),
      const FieldConfig('details', 'Details', FieldType.multiline),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Manager Approval', []),
      const ApprovalStepConfig('HR Approval', []),
      const ApprovalStepConfig('Director Approval', []),
    ],
  ),

  // 13. Hiring Request
  AiPresetConfig(
    keywords: ['hiring', '招聘', '招人'],
    name: 'Hiring Request',
    description: 'Department hiring and headcount request workflow',
    priority: 40,
    fields: [
      const FieldConfig('position', 'Position', FieldType.text, required: true),
      const FieldConfig('department', 'Department', FieldType.text,
          required: true),
      const FieldConfig('headcount', 'Headcount', FieldType.number,
          required: true),
      const FieldConfig('level', 'Level', FieldType.dropdown,
          options: ['Junior', 'Mid-level', 'Senior', 'Manager', 'Director']),
      const FieldConfig('salary_range', 'Salary Range', FieldType.text,
          placeholder: 'e.g., 10K-15K'),
      const FieldConfig(
          'justification', 'Hiring Justification', FieldType.multiline,
          required: true, placeholder: 'Explain the necessity of this hiring'),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Department Manager Approval', []),
      const ApprovalStepConfig('HR Approval', []),
    ],
  ),

  // 14. Project Initiation
  AiPresetConfig(
    keywords: ['project', '立项'],
    name: 'Project Initiation',
    description: 'New project initiation approval workflow',
    priority: 35,
    fields: [
      const FieldConfig('project_name', 'Project Name', FieldType.text,
          required: true),
      const FieldConfig('project_type', 'Project Type', FieldType.dropdown,
          required: true,
          options: ['R&D', 'Marketing', 'Operations', 'IT', 'Other']),
      const FieldConfig('budget', 'Budget', FieldType.currency, required: true),
      const FieldConfig(
          'description', 'Project Description', FieldType.multiline,
          required: true,
          placeholder: 'Describe project background, goals, and scope'),
      const FieldConfig('team_size', 'Team Size', FieldType.number),
      const FieldConfig('proposal', 'Project Proposal', FieldType.file),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Director Approval', []),
      const ApprovalStepConfig('Finance Approval', []),
      const ApprovalStepConfig('CEO Approval', []),
    ],
  ),

  // 15. General Request (Fallback)
  AiPresetConfig(
    keywords: ['request', 'approval', '通用', '其他', 'other'],
    name: 'General Request',
    description: 'General approval workflow for miscellaneous items',
    priority: 10,
    fields: [
      const FieldConfig('title', 'Request Title', FieldType.text,
          required: true),
      const FieldConfig('category', 'Category', FieldType.text,
          placeholder: 'Briefly describe the request type'),
      const FieldConfig('description', 'Description', FieldType.multiline,
          required: true, placeholder: 'Describe the request in detail'),
      const FieldConfig('attachments', 'Attachments', FieldType.file),
      const FieldConfig(
          'expected_date', 'Expected Completion Date', FieldType.date),
    ],
    approvalSteps: [
      const ApprovalStepConfig('Manager Approval', []),
    ],
  ),
];
