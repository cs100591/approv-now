# Mock Data Setup Guide

This guide explains how to create mock templates and approval requests for testing the Approve Now app with the `cs1005.91@gmail.com` account.

## 📋 What's Included

### 5 Templates with Approval Workflows:

1. **Expense Reimbursement** (2 levels)
   - Manager Review → Finance Approval (for amounts > $100)
   - Fields: Expense Type, Amount, Date, Description, Receipt

2. **Leave Request** (2 levels)
   - Direct Manager → HR Department (for > 5 days)
   - Fields: Leave Type, Start/End Dates, Days, Reason, Handover Notes

3. **Purchase Order** (3 levels)
   - Department Manager → Finance Review → Director Approval (for > $5000)
   - Fields: Vendor, Description, Amount, Category, Justification, Urgency, Quotes

4. **Document Review** (1 level)
   - Document Reviewer
   - Fields: Document Type, Title, Version, File, Review Notes

5. **Travel Request** (2 levels)
   - Manager Approval → Finance Approval (for > $2000)
   - Fields: Destination, Purpose, Dates, Cost, Accommodation

### Sample Requests (12+ total):
- **Pending requests** at different approval levels
- **Approved requests** with complete action history
- **Rejected requests** with feedback comments
- **Various scenarios** to test all features

---

## 🚀 Option 1: Use the App UI (Easiest)

Add the mock data screen to your app temporarily:

### Step 1: Navigate to the mock data screen

Add this route to your app router temporarily:

```dart
// In your router or main.dart, add:
MockDataScreen(), // Navigate to this screen
```

### Step 2: Run the generator
1. Launch the app
2. Navigate to the Mock Data screen
3. Click **"Generate Mock Data"**
4. Wait for confirmation
5. Check your templates and requests!

### Step 3: Remove when done
After generating mock data, remove the route from your app.

---

## 🗄️ Option 2: Run SQL Script (Direct to Database)

### Step 1: Open Supabase SQL Editor
1. Go to [Supabase Dashboard](https://app.supabase.io)
2. Select your project
3. Go to **SQL Editor** (left sidebar)
4. Click **"New query"**

### Step 2: Get Your IDs

Run this query first to get your actual workspace and user IDs:

```sql
-- Get your workspace ID
SELECT id, name FROM workspaces WHERE created_by = (
    SELECT id FROM auth.users WHERE email = 'cs1005.91@gmail.com'
);

-- Get your user ID
SELECT id FROM auth.users WHERE email = 'cs1005.91@gmail.com';
```

### Step 3: Update the Script

1. Open `scripts/mock_data.sql`
2. Replace these values:
   - `'mock-workspace-001'` → Your actual workspace ID
   - `'mock-user-001'` → Your actual user ID
3. Also update mock approver IDs (user-001, user-002, etc.) to real user IDs if you have them

### Step 4: Run the Script

Copy the updated SQL and paste it into the SQL Editor, then click **"Run"**.

### Step 5: Verify

```sql
-- Check templates
SELECT name, description FROM templates WHERE workspace_id = 'YOUR_WORKSPACE_ID';

-- Check requests
SELECT template_name, status, current_level 
FROM requests 
WHERE workspace_id = 'YOUR_WORKSPACE_ID';
```

---

## 🧪 Option 3: Dart Script (For Developers)

Create a standalone Dart script to insert data:

```dart
// scripts/insert_mock_data.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../lib/core/utils/mock_data_generator.dart';

void main() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  final templates = MockDataGenerator.generateTemplates();
  final requests = MockDataGenerator.generateRequests(templates);
  
  // Insert into Supabase...
  print('Mock data inserted!');
}
```

Run with: `dart scripts/insert_mock_data.dart`

---

## 📱 What You'll See in the App

After generating mock data, you'll see:

### Templates Screen
- 5 templates with different icons
- Various field types (text, dropdown, date, currency, file, checkbox)
- Multiple approval levels

### My Requests Screen
- Pending requests waiting for approval
- Approved requests with green checkmarks
- Rejected requests with red indicators
- Different templates represented

### Dashboard
- Pending approval counts
- Recent activity
- Status updates

---

## 🎯 Mock User Accounts

The mock data references these users as approvers:

| ID | Name | Role |
|----|------|------|
| user-001 | John Manager | Department Manager |
| user-002 | Sarah Finance | Finance Team |
| user-003 | Mike Director | Director |
| user-004 | Lisa HR | HR Department |
| user-005 | Tom Team Lead | Team Lead |

**Note:** These are placeholder IDs. Replace with actual user IDs from your workspace for realistic testing.

---

## 🗑️ Cleaning Up Mock Data

To remove all mock data:

```sql
-- Delete requests first (foreign key safety)
DELETE FROM requests 
WHERE workspace_id = 'YOUR_WORKSPACE_ID' 
AND submitted_by = 'YOUR_USER_ID';

-- Delete templates
DELETE FROM templates 
WHERE workspace_id = 'YOUR_WORKSPACE_ID' 
AND created_by = 'YOUR_USER_ID';
```

Or use the app to delete requests individually through the UI.

---

## ⚠️ Important Notes

1. **Test Environment**: Only use mock data in development/test workspaces
2. **User IDs**: Replace placeholder user IDs with real ones for proper testing
3. **Files**: File upload fields will show empty (no actual files uploaded)
4. **Notifications**: No real notifications sent since approvers are placeholders
5. **Emails**: Mock approvers won't receive real emails

---

## 🔧 Troubleshooting

### "Foreign key violation" error
- Make sure workspace_id and user_id are correct
- Ensure the workspace exists in the database

### "Permission denied" error
- Check Row Level Security (RLS) policies
- Verify you're logged in as the correct user

### Templates not showing
- Refresh the app
- Check that `is_active = true` in the database
- Verify workspace_id matches your current workspace

### Requests not appearing
- Check that the requests `submitted_by` matches your user ID
- Verify template_id references exist

---

## 💡 Tips

1. **Screenshot Testing**: Generate mock data before taking app screenshots
2. **Demo Mode**: Use mock data for app demos and presentations
3. **UI Testing**: Test all approval states (pending, approved, rejected)
4. **Multi-level Approvals**: The Purchase Order template has 3 levels - great for testing workflows

---

## 📞 Need Help?

If you encounter issues:
1. Check the browser console for errors
2. Verify your Supabase connection
3. Ensure RLS policies allow insert operations
4. Check that all required fields are populated