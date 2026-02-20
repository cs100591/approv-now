/**
 * Firebase Functions for Approve Now
 * Handles email notifications, invitations, and push notifications
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');
const Handlebars = require('handlebars');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
admin.initializeApp();

// Initialize SendGrid with API key from config
const SENDGRID_API_KEY = functions.config().sendgrid?.key || process.env.SENDGRID_API_KEY;
if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
}

// Email configuration
const EMAIL_CONFIG = {
  from: {
    email: functions.config().email?.from || 'noreply@approvenow.app',
    name: 'Approve Now'
  },
  replyTo: functions.config().email?.replyto || 'support@approvenow.app'
};

// Load email templates
const loadTemplate = (templateName) => {
  const templatePath = path.join(__dirname, 'templates', `${templateName}.html`);
  return fs.readFileSync(templatePath, 'utf8');
};

// Compile templates
const templates = {
  invitation: Handlebars.compile(loadTemplate('invitation-email'))
};

/**
 * Send invitation email when a new member is invited to a workspace
 */
exports.sendInvitationEmail = functions.firestore
  .document('workspaces/{workspaceId}/invitations/{invitationId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    const { workspaceId, invitationId } = context.params;

    console.log('Processing invitation:', invitationId);

    try {
      // Get workspace details
      const workspaceDoc = await admin.firestore()
        .doc(`workspaces/${workspaceId}`)
        .get();
      
      if (!workspaceDoc.exists) {
        console.error('Workspace not found:', workspaceId);
        return null;
      }

      const workspace = workspaceDoc.data();

      // Get inviter details
      const inviterDoc = await admin.firestore()
        .doc(`users/${invitation.invitedBy}`)
        .get();
      
      const inviter = inviterDoc.exists ? inviterDoc.data() : null;
      const inviterName = inviter?.displayName || inviter?.email || 'Someone';

      // Generate invite link with deep link
      const inviteLink = generateInviteLink({
        workspaceId,
        invitationId,
        token: invitation.token
      });

      const rejectLink = `${inviteLink}&action=reject`;

      // Get role-specific permissions
      const permissions = getRolePermissions(invitation.role);

      // Prepare email data
      const emailData = {
        workspaceName: workspace.name,
        inviterName,
        role: invitation.role,
        inviteLink,
        rejectLink,
        permissions
      };

      // Send email
      const msg = {
        to: invitation.email,
        from: EMAIL_CONFIG.from,
        replyTo: EMAIL_CONFIG.replyTo,
        subject: `${inviterName} invited you to join ${workspace.name} on Approve Now`,
        html: templates.invitation(emailData),
        text: generatePlainTextInvitation(emailData)
      };

      if (SENDGRID_API_KEY) {
        await sgMail.send(msg);
        console.log('Invitation email sent to:', invitation.email);
        
        // Update invitation status
        await snap.ref.update({
          emailSent: true,
          emailSentAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } else {
        console.log('SendGrid not configured. Email would have been sent:', msg);
      }

      return { success: true };
    } catch (error) {
      console.error('Error sending invitation email:', error);
      
      // Update invitation with error
      await snap.ref.update({
        emailSent: false,
        error: error.message
      });
      
      return { success: false, error: error.message };
    }
  });

/**
 * Send email notification for request status changes
 */
exports.sendRequestNotification = functions.firestore
  .document('workspaces/{workspaceId}/requests/{requestId}')
  .onUpdate(async (change, context) => {
    const { workspaceId, requestId } = context.params;
    const newData = change.after.data();
    const oldData = change.before.data();

    // Check if status changed
    if (newData.status === oldData.status) {
      return null;
    }

    console.log('Request status changed:', requestId, newData.status);

    try {
      // Get workspace details
      const workspaceDoc = await admin.firestore()
        .doc(`workspaces/${workspaceId}`)
        .get();
      
      const workspace = workspaceDoc.data();

      // Determine who to notify based on status change
      const notifications = [];

      if (newData.status === 'pending_approval') {
        // Notify approvers
        const currentLevel = newData.currentLevel || 1;
        const approvers = newData.approvalSteps?.[currentLevel - 1]?.approvers || [];
        
        for (const approverId of approvers) {
          const userDoc = await admin.firestore().doc(`users/${approverId}`).get();
          if (userDoc.exists) {
            const user = userDoc.data();
            if (user.email) {
              notifications.push({
                to: user.email,
                subject: `New approval request: ${newData.title}`,
                text: `A new request "${newData.title}" requires your approval in ${workspace.name}.`
              });
            }
          }
        }
      } else if (newData.status === 'approved' || newData.status === 'rejected') {
        // Notify request submitter
        const submitterDoc = await admin.firestore().doc(`users/${newData.submittedBy}`).get();
        if (submitterDoc.exists) {
          const submitter = submitterDoc.data();
          if (submitter.email) {
            const status = newData.status === 'approved' ? 'approved' : 'rejected';
            notifications.push({
              to: submitter.email,
              subject: `Request ${status}: ${newData.title}`,
              text: `Your request "${newData.title}" has been ${status} in ${workspace.name}.`
            });
          }
        }
      }

      // Send all notifications
      for (const notification of notifications) {
        const msg = {
          ...notification,
          from: EMAIL_CONFIG.from,
          replyTo: EMAIL_CONFIG.replyTo
        };

        if (SENDGRID_API_KEY) {
          await sgMail.send(msg);
          console.log('Notification sent to:', notification.to);
        } else {
          console.log('SendGrid not configured. Would have sent:', msg);
        }
      }

      return { success: true, notificationsSent: notifications.length };
    } catch (error) {
      console.error('Error sending request notification:', error);
      return { success: false, error: error.message };
    }
  });

/**
 * HTTP function to manually resend invitation email
 */
exports.resendInvitationEmail = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { workspaceId, invitationId } = data;

  if (!workspaceId || !invitationId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  try {
    // Get invitation
    const invitationDoc = await admin.firestore()
      .doc(`workspaces/${workspaceId}/invitations/${invitationId}`)
      .get();

    if (!invitationDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Invitation not found');
    }

    const invitation = invitationDoc.data();

    // Check if user has permission (must be admin or owner)
    const workspaceDoc = await admin.firestore()
      .doc(`workspaces/${workspaceId}`)
      .get();
    
    const workspace = workspaceDoc.data();
    const userId = context.auth.uid;
    
    const isAdmin = workspace.members?.some(
      m => m.userId === userId && (m.role === 'owner' || m.role === 'admin')
    );

    if (!isAdmin) {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can resend invitations');
    }

    // Trigger email by updating timestamp
    await invitationDoc.ref.update({
      resentAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true };
  } catch (error) {
    console.error('Error resending invitation:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Clean up expired invitations
 */
exports.cleanupExpiredInvitations = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const expirationDays = 7;
    const expirationDate = new Date(now.toDate());
    expirationDate.setDate(expirationDate.getDate() - expirationDays);

    try {
      // Find all expired invitations
      const expiredInvitations = await admin.firestore()
        .collectionGroup('invitations')
        .where('status', '==', 'pending')
        .where('createdAt', '<=', admin.firestore.Timestamp.fromDate(expirationDate))
        .get();

      const batch = admin.firestore().batch();
      let count = 0;

      expiredInvitations.docs.forEach(doc => {
        batch.update(doc.ref, {
          status: 'expired',
          expiredAt: admin.firestore.FieldValue.serverTimestamp()
        });
        count++;
      });

      await batch.commit();
      console.log(`Cleaned up ${count} expired invitations`);
      return { cleaned: count };
    } catch (error) {
      console.error('Error cleaning up invitations:', error);
      return { error: error.message };
    }
  });

// Helper functions
function generateInviteLink({ workspaceId, invitationId, token }) {
  const baseUrl = functions.config().app?.url || 'https://approvenow.app';
  return `${baseUrl}/invite?workspace=${workspaceId}&invitation=${invitationId}&token=${token}`;
}

function getRolePermissions(role) {
  const permissions = {
    'viewer': [
      'View requests and templates',
      'Receive notifications',
      'Download approved documents'
    ],
    'editor': [
      'Create and submit approval requests',
      'Approve/reject assigned requests',
      'View all requests and templates',
      'Edit their own requests'
    ],
    'admin': [
      'Manage workspace settings',
      'Invite and manage team members',
      'Create and edit templates',
      'All editor permissions'
    ],
    'owner': [
      'Full workspace control',
      'Delete workspace',
      'Billing and subscription management',
      'All admin permissions'
    ]
  };

  return permissions[role] || permissions['viewer'];
}

function generatePlainTextInvitation(data) {
  return `
Hello,

${data.inviterName} has invited you to join ${data.workspaceName} on Approve Now.

Role: ${data.role}

To accept this invitation, please visit:
${data.inviteLink}

What you can do with ${data.role} access:
${data.permissions.map(p => `- ${p}`).join('\n')}

This invitation will expire in 7 days.

If you didn't expect this invitation, you can ignore this email.

Best regards,
The Approve Now Team
  `.trim();
}

// Export for testing
module.exports = {
  generateInviteLink,
  getRolePermissions
};
