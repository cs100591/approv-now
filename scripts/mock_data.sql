-- Mock Data Insertion Script for Supabase
-- Run this in the Supabase SQL Editor to create sample templates and requests
-- For workspace: mock-workspace-001
-- For user: mock-user-001 (Demo User)

-- Note: Make sure to replace workspace_id and user_id with your actual IDs

DO $$
DECLARE
    v_workspace_id UUID := 'mock-workspace-001';
    v_user_id UUID := 'mock-user-001';
    v_user_name TEXT := 'Demo User';
    v_template_id_1 UUID;
    v_template_id_2 UUID;
    v_template_id_3 UUID;
    v_template_id_4 UUID;
    v_template_id_5 UUID;
BEGIN

-- ============================================
-- 1. CREATE TEMPLATES
-- ============================================

-- Template 1: Expense Reimbursement
INSERT INTO templates (
    id, workspace_id, name, description, fields, approval_steps, 
    is_active, created_by, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    'Expense Reimbursement',
    'Submit expense claims for business-related purchases',
    '[
        {"id": "1", "name": "expense_type", "label": "Expense Type", "type": "dropdown", "required": true, "order": 0, "options": ["Meals", "Transportation", "Office Supplies", "Software", "Training", "Other"]},
        {"id": "2", "name": "amount", "label": "Amount", "type": "currency", "required": true, "order": 1, "placeholder": "0.00"},
        {"id": "3", "name": "date", "label": "Date of Expense", "type": "date", "required": true, "order": 2},
        {"id": "4", "name": "description", "label": "Description", "type": "multiline", "required": true, "order": 3, "placeholder": "Provide details about this expense..."},
        {"id": "5", "name": "receipt", "label": "Receipt Attachment", "type": "file", "required": true, "order": 4}
    ]'::jsonb,
    '[
        {"id": "1", "level": 1, "name": "Manager Review", "approvers": ["user-001", "user-005"], "requireAll": false, "condition": "amount > 0"},
        {"id": "2", "level": 2, "name": "Finance Approval", "approvers": ["user-002"], "requireAll": true, "condition": "amount > 100"}
    ]'::jsonb,
    true,
    v_user_id,
    NOW(),
    NOW()
) RETURNING id INTO v_template_id_1;

-- Template 2: Leave Request
INSERT INTO templates (
    id, workspace_id, name, description, fields, approval_steps,
    is_active, created_by, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    'Leave Request',
    'Request time off including vacation, sick leave, or personal days',
    '[
        {"id": "1", "name": "leave_type", "label": "Leave Type", "type": "dropdown", "required": true, "order": 0, "options": ["Vacation", "Sick Leave", "Personal", "Bereavement", "Jury Duty"]},
        {"id": "2", "name": "start_date", "label": "Start Date", "type": "date", "required": true, "order": 1},
        {"id": "3", "name": "end_date", "label": "End Date", "type": "date", "required": true, "order": 2},
        {"id": "4", "name": "days", "label": "Number of Days", "type": "number", "required": true, "order": 3},
        {"id": "5", "name": "reason", "label": "Reason for Leave", "type": "multiline", "required": true, "order": 4, "placeholder": "Please provide details about your leave request..."},
        {"id": "6", "name": "handover", "label": "Work Handover Notes", "type": "multiline", "required": false, "order": 5, "placeholder": "Who will cover your responsibilities?"}
    ]'::jsonb,
    '[
        {"id": "1", "level": 1, "name": "Direct Manager", "approvers": ["user-001", "user-005"], "requireAll": false},
        {"id": "2", "level": 2, "name": "HR Department", "approvers": ["user-004"], "requireAll": true, "condition": "days > 5"}
    ]'::jsonb,
    true,
    v_user_id,
    NOW(),
    NOW()
) RETURNING id INTO v_template_id_2;

-- Template 3: Purchase Order
INSERT INTO templates (
    id, workspace_id, name, description, fields, approval_steps,
    is_active, created_by, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    'Purchase Order',
    'Request approval for business purchases over $500',
    '[
        {"id": "1", "name": "vendor", "label": "Vendor/Supplier", "type": "text", "required": true, "order": 0, "placeholder": "Company name"},
        {"id": "2", "name": "item_description", "label": "Item Description", "type": "multiline", "required": true, "order": 1, "placeholder": "Detailed description of items/services"},
        {"id": "3", "name": "total_amount", "label": "Total Amount", "type": "currency", "required": true, "order": 2},
        {"id": "4", "name": "category", "label": "Category", "type": "dropdown", "required": true, "order": 3, "options": ["Equipment", "Services", "Software", "Marketing", "Office Furniture", "Other"]},
        {"id": "5", "name": "justification", "label": "Business Justification", "type": "multiline", "required": true, "order": 4, "placeholder": "Why is this purchase necessary?"},
        {"id": "6", "name": "urgency", "label": "Urgency", "type": "dropdown", "required": true, "order": 5, "options": ["Low - Within 30 days", "Medium - Within 14 days", "High - Within 7 days", "Critical - Immediate"]},
        {"id": "7", "name": "quotes", "label": "Quote/Proposal", "type": "file", "required": true, "order": 6}
    ]'::jsonb,
    '[
        {"id": "1", "level": 1, "name": "Department Manager", "approvers": ["user-001"], "requireAll": true},
        {"id": "2", "level": 2, "name": "Finance Review", "approvers": ["user-002"], "requireAll": true},
        {"id": "3", "level": 3, "name": "Director Approval", "approvers": ["user-003"], "requireAll": true, "condition": "total_amount > 5000"}
    ]'::jsonb,
    true,
    v_user_id,
    NOW(),
    NOW()
) RETURNING id INTO v_template_id_3;

-- Template 4: Document Review
INSERT INTO templates (
    id, workspace_id, name, description, fields, approval_steps,
    is_active, created_by, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    'Document Review',
    'Submit documents for review and approval',
    '[
        {"id": "1", "name": "document_type", "label": "Document Type", "type": "dropdown", "required": true, "order": 0, "options": ["Contract", "Proposal", "Report", "Policy", "Technical Doc", "Other"]},
        {"id": "2", "name": "title", "label": "Document Title", "type": "text", "required": true, "order": 1},
        {"id": "3", "name": "version", "label": "Version Number", "type": "text", "required": true, "order": 2, "placeholder": "e.g., 1.0"},
        {"id": "4", "name": "document_file", "label": "Document File", "type": "file", "required": true, "order": 3},
        {"id": "5", "name": "review_notes", "label": "Notes for Reviewer", "type": "multiline", "required": false, "order": 4, "placeholder": "Any specific areas to focus on?"}
    ]'::jsonb,
    '[
        {"id": "1", "level": 1, "name": "Document Reviewer", "approvers": ["user-001", "user-003", "user-005"], "requireAll": false}
    ]'::jsonb,
    true,
    v_user_id,
    NOW(),
    NOW()
) RETURNING id INTO v_template_id_4;

-- Template 5: Travel Request
INSERT INTO templates (
    id, workspace_id, name, description, fields, approval_steps,
    is_active, created_by, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    'Travel Request',
    'Request approval for business travel',
    '[
        {"id": "1", "name": "destination", "label": "Destination", "type": "text", "required": true, "order": 0, "placeholder": "City, Country"},
        {"id": "2", "name": "purpose", "label": "Purpose of Travel", "type": "multiline", "required": true, "order": 1},
        {"id": "3", "name": "departure_date", "label": "Departure Date", "type": "date", "required": true, "order": 2},
        {"id": "4", "name": "return_date", "label": "Return Date", "type": "date", "required": true, "order": 3},
        {"id": "5", "name": "estimated_cost", "label": "Estimated Total Cost", "type": "currency", "required": true, "order": 4},
        {"id": "6", "name": "accommodation", "label": "Accommodation Required", "type": "checkbox", "required": false, "order": 5}
    ]'::jsonb,
    '[
        {"id": "1", "level": 1, "name": "Manager Approval", "approvers": ["user-001", "user-005"], "requireAll": false},
        {"id": "2", "level": 2, "name": "Finance Approval", "approvers": ["user-002"], "requireAll": true, "condition": "estimated_cost > 2000"}
    ]'::jsonb,
    true,
    v_user_id,
    NOW(),
    NOW()
) RETURNING id INTO v_template_id_5;

-- ============================================
-- 2. CREATE SAMPLE REQUESTS
-- ============================================

-- Request 1: Pending expense (level 1)
INSERT INTO requests (
    id, workspace_id, template_id, template_name, submitted_by, submitted_by_name,
    submitted_at, status, current_level, revision_number, field_values, approval_actions
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    v_template_id_1,
    'Expense Reimbursement',
    v_user_id,
    v_user_name,
    NOW() - INTERVAL '2 days',
    'pending',
    1,
    1,
    '[
        {"fieldId": "1", "fieldName": "expense_type", "fieldType": "dropdown", "value": "Meals"},
        {"fieldId": "2", "fieldName": "amount", "fieldType": "currency", "value": 85.50},
        {"fieldId": "3", "fieldName": "date", "fieldType": "date", "value": "' || (NOW() - INTERVAL '3 days')::date || '"},
        {"fieldId": "4", "fieldName": "description", "fieldType": "multiline", "value": "Client lunch meeting at Downtown Bistro"}
    ]'::jsonb,
    '[]'::jsonb
);

-- Request 2: Approved expense
INSERT INTO requests (
    id, workspace_id, template_id, template_name, submitted_by, submitted_by_name,
    submitted_at, status, current_level, revision_number, field_values, approval_actions
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    v_template_id_1,
    'Expense Reimbursement',
    v_user_id,
    v_user_name,
    NOW() - INTERVAL '10 days',
    'approved',
    3,
    1,
    '[
        {"fieldId": "1", "fieldName": "expense_type", "fieldType": "dropdown", "value": "Office Supplies"},
        {"fieldId": "2", "fieldName": "amount", "fieldType": "currency", "value": 45.99},
        {"fieldId": "3", "fieldName": "date", "fieldType": "date", "value": "' || (NOW() - INTERVAL '10 days')::date || '"},
        {"fieldId": "4", "fieldName": "description", "fieldType": "multiline", "value": "Printer paper and pens"}
    ]'::jsonb,
    '[
        {"id": "' || gen_random_uuid() || '", "level": 1, "approverId": "user-001", "approverName": "John Manager", "approved": true, "comment": "Approved - reasonable expense", "timestamp": "' || (NOW() - INTERVAL '9 days') || '"},
        {"id": "' || gen_random_uuid() || '", "level": 2, "approverId": "user-002", "approverName": "Sarah Finance", "approved": true, "comment": "Looks good", "timestamp": "' || (NOW() - INTERVAL '8 days') || '"}
    ]'::jsonb
);

-- Request 3: Rejected expense
INSERT INTO requests (
    id, workspace_id, template_id, template_name, submitted_by, submitted_by_name,
    submitted_at, status, current_level, revision_number, field_values, approval_actions
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    v_template_id_1,
    'Expense Reimbursement',
    v_user_id,
    v_user_name,
    NOW() - INTERVAL '5 days',
    'rejected',
    1,
    1,
    '[
        {"fieldId": "1", "fieldName": "expense_type", "fieldType": "dropdown", "value": "Software"},
        {"fieldId": "2", "fieldName": "amount", "fieldType": "currency", "value": 299.99},
        {"fieldId": "3", "fieldName": "date", "fieldType": "date", "value": "' || (NOW() - INTERVAL '5 days')::date || '"},
        {"fieldId": "4", "fieldName": "description", "fieldType": "multiline", "value": "Personal productivity software license"}
    ]'::jsonb,
    '[
        {"id": "' || gen_random_uuid() || '", "level": 1, "approverId": "user-001", "approverName": "John Manager", "approved": false, "comment": "Please use company-provided tools instead. Contact IT for alternatives.", "timestamp": "' || (NOW() - INTERVAL '4 days') || '"}
    ]'::jsonb
);

-- Request 4: Pending leave (level 1)
INSERT INTO requests (
    id, workspace_id, template_id, template_name, submitted_by, submitted_by_name,
    submitted_at, status, current_level, revision_number, field_values, approval_actions
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    v_template_id_2,
    'Leave Request',
    v_user_id,
    v_user_name,
    NOW() - INTERVAL '3 days',
    'pending',
    1,
    1,
    '[
        {"fieldId": "1", "fieldName": "leave_type", "fieldType": "dropdown", "value": "Vacation"},
        {"fieldId": "2", "fieldName": "start_date", "fieldType": "date", "value": "' || (NOW() + INTERVAL '14 days')::date || '"},
        {"fieldId": "3", "fieldName": "end_date", "fieldType": "date", "value": "' || (NOW() + INTERVAL '21 days')::date || '"},
        {"fieldId": "4", "fieldName": "days", "fieldType": "number", "value": 5},
        {"fieldId": "5", "fieldName": "reason", "fieldType": "multiline", "value": "Family vacation to Hawaii"}
    ]'::jsonb,
    '[]'::jsonb
);

-- Request 5: Pending purchase order (high value, level 2)
INSERT INTO requests (
    id, workspace_id, template_id, template_name, submitted_by, submitted_by_name,
    submitted_at, status, current_level, revision_number, field_values, approval_actions
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    v_template_id_3,
    'Purchase Order',
    v_user_id,
    v_user_name,
    NOW() - INTERVAL '2 days',
    'pending',
    2,
    1,
    '[
        {"fieldId": "1", "fieldName": "vendor", "fieldType": "text", "value": "Dell Technologies"},
        {"fieldId": "2", "fieldName": "item_description", "fieldType": "multiline", "value": "3x Dell XPS 15 laptops for new developers joining next month"},
        {"fieldId": "3", "fieldName": "total_amount", "fieldType": "currency", "value": 7200.00},
        {"fieldId": "4", "fieldName": "category", "fieldType": "dropdown", "value": "Equipment"},
        {"fieldId": "5", "fieldName": "justification", "fieldType": "multiline", "value": "New hires starting March 1st need development machines. Dell XPS 15 is standard for engineering team."},
        {"fieldId": "6", "fieldName": "urgency", "fieldType": "dropdown", "value": "Medium - Within 14 days"}
    ]'::jsonb,
    '[
        {"id": "' || gen_random_uuid() || '", "level": 1, "approverId": "user-001", "approverName": "John Manager", "approved": true, "comment": "Approved. Critical for onboarding.", "timestamp": "' || (NOW() - INTERVAL '1 days') || '"}
    ]'::jsonb
);

-- Request 6: Pending travel
INSERT INTO requests (
    id, workspace_id, template_id, template_name, submitted_by, submitted_by_name,
    submitted_at, status, current_level, revision_number, field_values, approval_actions
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    v_template_id_5,
    'Travel Request',
    v_user_id,
    v_user_name,
    NOW() - INTERVAL '2 days',
    'pending',
    1,
    1,
    '[
        {"fieldId": "1", "fieldName": "destination", "fieldType": "text", "value": "San Francisco, CA"},
        {"fieldId": "2", "fieldName": "purpose", "fieldType": "multiline", "value": "Attend Flutter Forward conference and meet with potential clients"},
        {"fieldId": "3", "fieldName": "departure_date", "fieldType": "date", "value": "' || (NOW() + INTERVAL '30 days')::date || '"},
        {"fieldId": "4", "fieldName": "return_date", "fieldType": "date", "value": "' || (NOW() + INTERVAL '33 days')::date || '"},
        {"fieldId": "5", "fieldName": "estimated_cost", "fieldType": "currency", "value": 2850.00},
        {"fieldId": "6", "fieldName": "accommodation", "fieldType": "checkbox", "value": true}
    ]'::jsonb,
    '[]'::jsonb
);

-- Request 7: Pending document review
INSERT INTO requests (
    id, workspace_id, template_id, template_name, submitted_by, submitted_by_name,
    submitted_at, status, current_level, revision_number, field_values, approval_actions
) VALUES (
    gen_random_uuid(),
    v_workspace_id,
    v_template_id_4,
    'Document Review',
    v_user_id,
    v_user_name,
    NOW() - INTERVAL '5 hours',
    'pending',
    1,
    1,
    '[
        {"fieldId": "1", "fieldName": "document_type", "fieldType": "dropdown", "value": "Proposal"},
        {"fieldId": "2", "fieldName": "title", "fieldType": "text", "value": "Q2 Marketing Campaign Proposal"},
        {"fieldId": "3", "fieldName": "version", "fieldType": "text", "value": "2.1"},
        {"fieldId": "5", "fieldName": "review_notes", "fieldType": "multiline", "value": "Please focus on budget section - increased from previous version"}
    ]'::jsonb,
    '[]'::jsonb
);

RAISE NOTICE '✅ Mock data created successfully!';
RAISE NOTICE '📋 Created 5 templates';
RAISE NOTICE '📄 Created 7 sample requests';

END $$;

-- ============================================
-- USAGE INSTRUCTIONS
-- ============================================
-- 1. Replace 'mock-workspace-001' with your actual workspace ID
-- 2. Replace 'mock-user-001' with your actual user ID
-- 3. Run this script in Supabase SQL Editor
-- 4. The mock users (user-001, user-002, etc.) are placeholders
--    Replace them with actual user IDs from your workspace
--
-- To view the created data:
--   SELECT * FROM templates WHERE workspace_id = 'your-workspace-id';
--   SELECT * FROM requests WHERE workspace_id = 'your-workspace-id';
--
-- To delete mock data:
--   DELETE FROM requests WHERE workspace_id = 'your-workspace-id';
--   DELETE FROM templates WHERE workspace_id = 'your-workspace-id';