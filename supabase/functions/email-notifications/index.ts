// Supabase Edge Function: Email Notifications
// This function handles sending email notifications for the Approv Now app

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Resend HTTP API Endpoint
const RESEND_API_URL = 'https://api.resend.com/emails';

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Email notifications are disabled
  // This function is kept for API compatibility but does not send emails
  console.log('Email notifications are disabled')
  
  return new Response(
    JSON.stringify({ 
      success: true, 
      message: 'Email notifications are currently disabled' 
    }),
    {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    }
  )
})

// === RESEND EMAIL FUNCTIONS ===

async function sendEmailViaResend(apiKey: string, payload: any) {
  const response = await fetch(RESEND_API_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error(`Resend API Error: ${errorText}`);
    throw new Error(`Resend API error: ${response.statusText}`);
  }

  return response.json();
}

function getSenderEmail() {
  // Use user-defined email or fallback, domains MUST be verified on Resend
  return Deno.env.get('EMAIL_FROM') || 'notifications@approvnow.com';
}

async function sendInvitationEmail(apiKey: string, data: any) {
  const { email, workspaceName, inviterName, inviteToken } = data;
  const inviteLink = `${Deno.env.get('APP_URL')}/invite?token=${inviteToken}`;

  await sendEmailViaResend(apiKey, {
    from: `Approv Now <${getSenderEmail()}>`,
    to: [email],
    subject: `You have been invited to join ${workspaceName}`,
    html: `
      <h2>You're Invited!</h2>
      <p><strong>${inviterName}</strong> has invited you to join their workspace: <strong>${workspaceName}</strong> on Approv Now.</p>
      <p>Click the link below to accept the invitation and get started:</p>
      <a href="${inviteLink}" style="display:inline-block;padding:10px 20px;background-color:#0175C2;color:#ffffff;text-decoration:none;border-radius:5px;">Join Workspace</a>
      <p><br>Or copy this link to your browser: <br><small>${inviteLink}</small></p>
    `,
  });

  return { type: 'invitation', email };
}

async function sendApprovalRequestEmail(apiKey: string, data: any) {
  const { email, requestorName, templateName, workspaceName } = data;

  await sendEmailViaResend(apiKey, {
    from: `Approv Now <${getSenderEmail()}>`,
    to: [email],
    subject: `Action Required: New Approval Request in ${workspaceName}`,
    html: `
      <h2>New Approval Request</h2>
      <p><strong>${requestorName}</strong> has submitted a new request using the <strong>${templateName}</strong> template in the <strong>${workspaceName}</strong> workspace.</p>
      <p>Please open the Approv Now app or dashboard to review and approve this request.</p>
    `,
  });

  return { type: 'approval_request', email };
}

async function sendApprovalCompletedEmail(apiKey: string, data: any) {
  const { email, templateName, workspaceName } = data;

  await sendEmailViaResend(apiKey, {
    from: `Approv Now <${getSenderEmail()}>`,
    to: [email],
    subject: `Approved: ${templateName} Request in ${workspaceName}`,
    html: `
      <h2>Request Approved</h2>
      <p>Good news! Your recent <strong>${templateName}</strong> request in the <strong>${workspaceName}</strong> workspace has been fully approved by all required parties.</p>
      <p>You can view the final approved document in the Approv Now app.</p>
    `,
  });

  return { type: 'approval_completed', email };
}

async function sendRejectionEmail(apiKey: string, data: any) {
  const { email, templateName, workspaceName, reason } = data;

  let reasonHtml = '';
  if (reason && reason.trim().length > 0) {
    reasonHtml = `<p><strong>Reason provided:</strong> <em>"${reason}"</em></p>`;
  }

  await sendEmailViaResend(apiKey, {
    from: `Approv Now <${getSenderEmail()}>`,
    to: [email],
    subject: `Rejected: ${templateName} Request in ${workspaceName}`,
    html: `
      <h2>Request Rejected</h2>
      <p>Your recent <strong>${templateName}</strong> request in the <strong>${workspaceName}</strong> workspace has been rejected.</p>
      ${reasonHtml}
      <p>Please open the Approv Now app to review the feedback and submit a revised version if necessary.</p>
    `,
  });

  return { type: 'request_rejected', email };
}
