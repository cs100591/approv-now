import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../modules/template/template_models.dart';
import '../../modules/request/request_models.dart';

/// Utility class to generate mock data for development
class MockDataGenerator {
  static const _uuid = Uuid();
  static final _random = Random();

  // Mock user IDs and names for cs1005.91@gmail.com account
  static const String currentUserId = 'mock-user-001';
  static const String currentUserName = 'Demo User';
  static const String workspaceId = 'mock-workspace-001';

  // Other mock users for approvals
  static final List<Map<String, String>> _mockUsers = [
    {'id': 'user-001', 'name': 'John Manager'},
    {'id': 'user-002', 'name': 'Sarah Finance'},
    {'id': 'user-003', 'name': 'Mike Director'},
    {'id': 'user-004', 'name': 'Lisa HR'},
    {'id': 'user-005', 'name': 'Tom Team Lead'},
  ];

  /// Generate all mock templates
  static List<Template> generateTemplates() {
    return [
      _expenseApprovalTemplate(),
      _leaveRequestTemplate(),
      _purchaseOrderTemplate(),
      _documentReviewTemplate(),
      _travelRequestTemplate(),
    ];
  }

  /// Generate sample requests for each template
  static List<ApprovalRequest> generateRequests(List<Template> templates) {
    final requests = <ApprovalRequest>[];

    // Expense requests
    requests.addAll(_generateExpenseRequests(templates[0]));

    // Leave requests
    requests.addAll(_generateLeaveRequests(templates[1]));

    // Purchase orders
    requests.addAll(_generatePurchaseOrderRequests(templates[2]));

    // Document reviews
    requests.addAll(_generateDocumentRequests(templates[3]));

    // Travel requests
    requests.addAll(_generateTravelRequests(templates[4]));

    return requests;
  }

  /// Expense Approval Template (2 levels: Manager → Finance)
  static Template _expenseApprovalTemplate() {
    return Template(
      id: _uuid.v4(),
      workspaceId: workspaceId,
      name: 'Expense Reimbursement',
      description: 'Submit expense claims for business-related purchases',
      fields: [
        TemplateField(
          id: _uuid.v4(),
          name: 'expense_type',
          label: 'Expense Type',
          type: FieldType.dropdown,
          required: true,
          order: 0,
          options: [
            'Meals',
            'Transportation',
            'Office Supplies',
            'Software',
            'Training',
            'Other'
          ],
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'amount',
          label: 'Amount',
          type: FieldType.currency,
          required: true,
          order: 1,
          placeholder: '0.00',
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'date',
          label: 'Date of Expense',
          type: FieldType.date,
          required: true,
          order: 2,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'description',
          label: 'Description',
          type: FieldType.multiline,
          required: true,
          order: 3,
          placeholder: 'Provide details about this expense...',
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'receipt',
          label: 'Receipt Attachment',
          type: FieldType.file,
          required: true,
          order: 4,
        ),
      ],
      approvalSteps: [
        ApprovalStep(
          id: _uuid.v4(),
          level: 1,
          name: 'Manager Review',
          approvers: ['user-001', 'user-005'], // John Manager, Tom Team Lead
          requireAll: false,
          condition: 'amount > 0',
        ),
        ApprovalStep(
          id: _uuid.v4(),
          level: 2,
          name: 'Finance Approval',
          approvers: ['user-002'], // Sarah Finance
          requireAll: true,
          condition: 'amount > 100',
        ),
      ],
      createdBy: currentUserId,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  /// Leave Request Template (2 levels: Manager → HR)
  static Template _leaveRequestTemplate() {
    return Template(
      id: _uuid.v4(),
      workspaceId: workspaceId,
      name: 'Leave Request',
      description:
          'Request time off including vacation, sick leave, or personal days',
      fields: [
        TemplateField(
          id: _uuid.v4(),
          name: 'leave_type',
          label: 'Leave Type',
          type: FieldType.dropdown,
          required: true,
          order: 0,
          options: [
            'Vacation',
            'Sick Leave',
            'Personal',
            'Bereavement',
            'Jury Duty'
          ],
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'start_date',
          label: 'Start Date',
          type: FieldType.date,
          required: true,
          order: 1,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'end_date',
          label: 'End Date',
          type: FieldType.date,
          required: true,
          order: 2,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'days',
          label: 'Number of Days',
          type: FieldType.number,
          required: true,
          order: 3,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'reason',
          label: 'Reason for Leave',
          type: FieldType.multiline,
          required: true,
          order: 4,
          placeholder: 'Please provide details about your leave request...',
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'handover',
          label: 'Work Handover Notes',
          type: FieldType.multiline,
          required: false,
          order: 5,
          placeholder: 'Who will cover your responsibilities?',
        ),
      ],
      approvalSteps: [
        ApprovalStep(
          id: _uuid.v4(),
          level: 1,
          name: 'Direct Manager',
          approvers: ['user-001', 'user-005'],
          requireAll: false,
        ),
        ApprovalStep(
          id: _uuid.v4(),
          level: 2,
          name: 'HR Department',
          approvers: ['user-004'], // Lisa HR
          requireAll: true,
          condition: 'days > 5',
        ),
      ],
      createdBy: currentUserId,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 25)),
    );
  }

  /// Purchase Order Template (3 levels: Manager → Finance → Director)
  static Template _purchaseOrderTemplate() {
    return Template(
      id: _uuid.v4(),
      workspaceId: workspaceId,
      name: 'Purchase Order',
      description: 'Request approval for business purchases over \$500',
      fields: [
        TemplateField(
          id: _uuid.v4(),
          name: 'vendor',
          label: 'Vendor/Supplier',
          type: FieldType.text,
          required: true,
          order: 0,
          placeholder: 'Company name',
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'item_description',
          label: 'Item Description',
          type: FieldType.multiline,
          required: true,
          order: 1,
          placeholder: 'Detailed description of items/services',
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'total_amount',
          label: 'Total Amount',
          type: FieldType.currency,
          required: true,
          order: 2,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'category',
          label: 'Category',
          type: FieldType.dropdown,
          required: true,
          order: 3,
          options: [
            'Equipment',
            'Services',
            'Software',
            'Marketing',
            'Office Furniture',
            'Other'
          ],
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'justification',
          label: 'Business Justification',
          type: FieldType.multiline,
          required: true,
          order: 4,
          placeholder: 'Why is this purchase necessary?',
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'urgency',
          label: 'Urgency',
          type: FieldType.dropdown,
          required: true,
          order: 5,
          options: [
            'Low - Within 30 days',
            'Medium - Within 14 days',
            'High - Within 7 days',
            'Critical - Immediate'
          ],
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'quotes',
          label: 'Quote/Proposal',
          type: FieldType.file,
          required: true,
          order: 6,
        ),
      ],
      approvalSteps: [
        ApprovalStep(
          id: _uuid.v4(),
          level: 1,
          name: 'Department Manager',
          approvers: ['user-001'],
          requireAll: true,
        ),
        ApprovalStep(
          id: _uuid.v4(),
          level: 2,
          name: 'Finance Review',
          approvers: ['user-002'],
          requireAll: true,
        ),
        ApprovalStep(
          id: _uuid.v4(),
          level: 3,
          name: 'Director Approval',
          approvers: ['user-003'], // Mike Director
          requireAll: true,
          condition: 'total_amount > 5000',
        ),
      ],
      createdBy: currentUserId,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    );
  }

  /// Document Review Template (1 level: Direct approval)
  static Template _documentReviewTemplate() {
    return Template(
      id: _uuid.v4(),
      workspaceId: workspaceId,
      name: 'Document Review',
      description: 'Submit documents for review and approval',
      fields: [
        TemplateField(
          id: _uuid.v4(),
          name: 'document_type',
          label: 'Document Type',
          type: FieldType.dropdown,
          required: true,
          order: 0,
          options: [
            'Contract',
            'Proposal',
            'Report',
            'Policy',
            'Technical Doc',
            'Other'
          ],
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'title',
          label: 'Document Title',
          type: FieldType.text,
          required: true,
          order: 1,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'version',
          label: 'Version Number',
          type: FieldType.text,
          required: true,
          order: 2,
          placeholder: 'e.g., 1.0',
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'document_file',
          label: 'Document File',
          type: FieldType.file,
          required: true,
          order: 3,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'review_notes',
          label: 'Notes for Reviewer',
          type: FieldType.multiline,
          required: false,
          order: 4,
          placeholder: 'Any specific areas to focus on?',
        ),
      ],
      approvalSteps: [
        ApprovalStep(
          id: _uuid.v4(),
          level: 1,
          name: 'Document Reviewer',
          approvers: ['user-001', 'user-003', 'user-005'],
          requireAll: false,
        ),
      ],
      createdBy: currentUserId,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    );
  }

  /// Travel Request Template (2 levels)
  static Template _travelRequestTemplate() {
    return Template(
      id: _uuid.v4(),
      workspaceId: workspaceId,
      name: 'Travel Request',
      description: 'Request approval for business travel',
      fields: [
        TemplateField(
          id: _uuid.v4(),
          name: 'destination',
          label: 'Destination',
          type: FieldType.text,
          required: true,
          order: 0,
          placeholder: 'City, Country',
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'purpose',
          label: 'Purpose of Travel',
          type: FieldType.multiline,
          required: true,
          order: 1,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'departure_date',
          label: 'Departure Date',
          type: FieldType.date,
          required: true,
          order: 2,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'return_date',
          label: 'Return Date',
          type: FieldType.date,
          required: true,
          order: 3,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'estimated_cost',
          label: 'Estimated Total Cost',
          type: FieldType.currency,
          required: true,
          order: 4,
        ),
        TemplateField(
          id: _uuid.v4(),
          name: 'accommodation',
          label: 'Accommodation Required',
          type: FieldType.checkbox,
          required: false,
          order: 5,
        ),
      ],
      approvalSteps: [
        ApprovalStep(
          id: _uuid.v4(),
          level: 1,
          name: 'Manager Approval',
          approvers: ['user-001', 'user-005'],
          requireAll: false,
        ),
        ApprovalStep(
          id: _uuid.v4(),
          level: 2,
          name: 'Finance Approval',
          approvers: ['user-002'],
          requireAll: true,
          condition: 'estimated_cost > 2000',
        ),
      ],
      createdBy: currentUserId,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    );
  }

  // Generate sample expense requests
  static List<ApprovalRequest> _generateExpenseRequests(Template template) {
    return [
      // Pending at level 1
      _createRequest(
        template: template,
        status: RequestStatus.pending,
        currentLevel: 1,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'expense_type',
            fieldType: FieldType.dropdown,
            value: 'Meals',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'amount',
            fieldType: FieldType.currency,
            value: 85.50,
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'date',
            fieldType: FieldType.date,
            value: DateTime.now().subtract(const Duration(days: 3)),
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'description',
            fieldType: FieldType.multiline,
            value: 'Client lunch meeting at Downtown Bistro',
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // Approved
      _createRequest(
        template: template,
        status: RequestStatus.approved,
        currentLevel: 3, // Past all levels
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'expense_type',
            fieldType: FieldType.dropdown,
            value: 'Office Supplies',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'amount',
            fieldType: FieldType.currency,
            value: 45.99,
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'date',
            fieldType: FieldType.date,
            value: DateTime.now().subtract(const Duration(days: 10)),
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'description',
            fieldType: FieldType.multiline,
            value: 'Printer paper and pens',
          ),
        ],
        approvalActions: [
          ApprovalAction(
            id: _uuid.v4(),
            level: 1,
            approverId: 'user-001',
            approverName: 'John Manager',
            approved: true,
            comment: 'Approved - reasonable expense',
            timestamp: DateTime.now().subtract(const Duration(days: 9)),
          ),
          ApprovalAction(
            id: _uuid.v4(),
            level: 2,
            approverId: 'user-002',
            approverName: 'Sarah Finance',
            approved: true,
            comment: 'Looks good',
            timestamp: DateTime.now().subtract(const Duration(days: 8)),
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      // Rejected
      _createRequest(
        template: template,
        status: RequestStatus.rejected,
        currentLevel: 1,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'expense_type',
            fieldType: FieldType.dropdown,
            value: 'Software',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'amount',
            fieldType: FieldType.currency,
            value: 299.99,
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'date',
            fieldType: FieldType.date,
            value: DateTime.now().subtract(const Duration(days: 5)),
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'description',
            fieldType: FieldType.multiline,
            value: 'Personal productivity software license',
          ),
        ],
        approvalActions: [
          ApprovalAction(
            id: _uuid.v4(),
            level: 1,
            approverId: 'user-001',
            approverName: 'John Manager',
            approved: false,
            comment:
                'Please use company-provided tools instead. Contact IT for alternatives.',
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // Pending at level 2
      _createRequest(
        template: template,
        status: RequestStatus.pending,
        currentLevel: 2,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'expense_type',
            fieldType: FieldType.dropdown,
            value: 'Training',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'amount',
            fieldType: FieldType.currency,
            value: 450.00,
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'date',
            fieldType: FieldType.date,
            value: DateTime.now().subtract(const Duration(days: 1)),
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'description',
            fieldType: FieldType.multiline,
            value: 'Flutter certification course - professional development',
          ),
        ],
        approvalActions: [
          ApprovalAction(
            id: _uuid.v4(),
            level: 1,
            approverId: 'user-005',
            approverName: 'Tom Team Lead',
            approved: true,
            comment: 'Great for the team! Approved.',
            timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Generate sample leave requests
  static List<ApprovalRequest> _generateLeaveRequests(Template template) {
    return [
      // Pending vacation
      _createRequest(
        template: template,
        status: RequestStatus.pending,
        currentLevel: 1,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'leave_type',
            fieldType: FieldType.dropdown,
            value: 'Vacation',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'start_date',
            fieldType: FieldType.date,
            value: DateTime.now().add(const Duration(days: 14)),
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'end_date',
            fieldType: FieldType.date,
            value: DateTime.now().add(const Duration(days: 21)),
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'days',
            fieldType: FieldType.number,
            value: 5,
          ),
          FieldValue(
            fieldId: template.fields[4].id,
            fieldName: 'reason',
            fieldType: FieldType.multiline,
            value: 'Family vacation to Hawaii',
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // Approved sick leave
      _createRequest(
        template: template,
        status: RequestStatus.approved,
        currentLevel: 2,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'leave_type',
            fieldType: FieldType.dropdown,
            value: 'Sick Leave',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'start_date',
            fieldType: FieldType.date,
            value: DateTime.now().subtract(const Duration(days: 7)),
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'end_date',
            fieldType: FieldType.date,
            value: DateTime.now().subtract(const Duration(days: 5)),
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'days',
            fieldType: FieldType.number,
            value: 2,
          ),
          FieldValue(
            fieldId: template.fields[4].id,
            fieldName: 'reason',
            fieldType: FieldType.multiline,
            value: 'Flu recovery - doctor confirmed',
          ),
        ],
        approvalActions: [
          ApprovalAction(
            id: _uuid.v4(),
            level: 1,
            approverId: 'user-001',
            approverName: 'John Manager',
            approved: true,
            comment: 'Get well soon!',
            timestamp: DateTime.now().subtract(const Duration(days: 6)),
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  // Generate sample purchase order requests
  static List<ApprovalRequest> _generatePurchaseOrderRequests(
      Template template) {
    return [
      // Pending at level 2 (high value)
      _createRequest(
        template: template,
        status: RequestStatus.pending,
        currentLevel: 2,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'vendor',
            fieldType: FieldType.text,
            value: 'Dell Technologies',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'item_description',
            fieldType: FieldType.multiline,
            value:
                '3x Dell XPS 15 laptops for new developers joining next month',
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'total_amount',
            fieldType: FieldType.currency,
            value: 7200.00,
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'category',
            fieldType: FieldType.dropdown,
            value: 'Equipment',
          ),
          FieldValue(
            fieldId: template.fields[4].id,
            fieldName: 'justification',
            fieldType: FieldType.multiline,
            value:
                'New hires starting March 1st need development machines. Dell XPS 15 is standard for engineering team.',
          ),
          FieldValue(
            fieldId: template.fields[5].id,
            fieldName: 'urgency',
            fieldType: FieldType.dropdown,
            value: 'Medium - Within 14 days',
          ),
        ],
        approvalActions: [
          ApprovalAction(
            id: _uuid.v4(),
            level: 1,
            approverId: 'user-001',
            approverName: 'John Manager',
            approved: true,
            comment: 'Approved. Critical for onboarding.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // Approved small purchase
      _createRequest(
        template: template,
        status: RequestStatus.approved,
        currentLevel: 3,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'vendor',
            fieldType: FieldType.text,
            value: 'Amazon Business',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'item_description',
            fieldType: FieldType.multiline,
            value: 'Ergonomic office chairs (2 units)',
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'total_amount',
            fieldType: FieldType.currency,
            value: 650.00,
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'category',
            fieldType: FieldType.dropdown,
            value: 'Office Furniture',
          ),
          FieldValue(
            fieldId: template.fields[4].id,
            fieldName: 'justification',
            fieldType: FieldType.multiline,
            value: 'Employee wellness initiative - replace old chairs',
          ),
        ],
        approvalActions: [
          ApprovalAction(
            id: _uuid.v4(),
            level: 1,
            approverId: 'user-001',
            approverName: 'John Manager',
            approved: true,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ApprovalAction(
            id: _uuid.v4(),
            level: 2,
            approverId: 'user-002',
            approverName: 'Sarah Finance',
            approved: true,
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }

  // Generate sample document requests
  static List<ApprovalRequest> _generateDocumentRequests(Template template) {
    return [
      // Pending document review
      _createRequest(
        template: template,
        status: RequestStatus.pending,
        currentLevel: 1,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'document_type',
            fieldType: FieldType.dropdown,
            value: 'Proposal',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'title',
            fieldType: FieldType.text,
            value: 'Q2 Marketing Campaign Proposal',
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'version',
            fieldType: FieldType.text,
            value: '2.1',
          ),
          FieldValue(
            fieldId: template.fields[4].id,
            fieldName: 'review_notes',
            fieldType: FieldType.multiline,
            value:
                'Please focus on budget section - increased from previous version',
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),

      // Approved contract
      _createRequest(
        template: template,
        status: RequestStatus.approved,
        currentLevel: 2,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'document_type',
            fieldType: FieldType.dropdown,
            value: 'Contract',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'title',
            fieldType: FieldType.text,
            value: 'Vendor Agreement - Cloud Services',
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'version',
            fieldType: FieldType.text,
            value: 'Final',
          ),
        ],
        approvalActions: [
          ApprovalAction(
            id: _uuid.v4(),
            level: 1,
            approverId: 'user-003',
            approverName: 'Mike Director',
            approved: true,
            comment: 'All terms reviewed and accepted. Good to proceed.',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  // Generate sample travel requests
  static List<ApprovalRequest> _generateTravelRequests(Template template) {
    return [
      // Pending travel
      _createRequest(
        template: template,
        status: RequestStatus.pending,
        currentLevel: 1,
        fieldValues: [
          FieldValue(
            fieldId: template.fields[0].id,
            fieldName: 'destination',
            fieldType: FieldType.text,
            value: 'San Francisco, CA',
          ),
          FieldValue(
            fieldId: template.fields[1].id,
            fieldName: 'purpose',
            fieldType: FieldType.multiline,
            value:
                'Attend Flutter Forward conference and meet with potential clients',
          ),
          FieldValue(
            fieldId: template.fields[2].id,
            fieldName: 'departure_date',
            fieldType: FieldType.date,
            value: DateTime.now().add(const Duration(days: 30)),
          ),
          FieldValue(
            fieldId: template.fields[3].id,
            fieldName: 'return_date',
            fieldType: FieldType.date,
            value: DateTime.now().add(const Duration(days: 33)),
          ),
          FieldValue(
            fieldId: template.fields[4].id,
            fieldName: 'estimated_cost',
            fieldType: FieldType.currency,
            value: 2850.00,
          ),
          FieldValue(
            fieldId: template.fields[5].id,
            fieldName: 'accommodation',
            fieldType: FieldType.checkbox,
            value: true,
          ),
        ],
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // Helper method to create a request
  static ApprovalRequest _createRequest({
    required Template template,
    required RequestStatus status,
    required int currentLevel,
    required List<FieldValue> fieldValues,
    List<ApprovalAction> approvalActions = const [],
    required DateTime submittedAt,
  }) {
    return ApprovalRequest(
      id: _uuid.v4(),
      workspaceId: workspaceId,
      templateId: template.id,
      templateName: template.name,
      submittedBy: currentUserId,
      submittedByName: currentUserName,
      submittedAt: submittedAt,
      status: status,
      currentLevel: currentLevel,
      fieldValues: fieldValues,
      approvalActions: approvalActions,
    );
  }
}
