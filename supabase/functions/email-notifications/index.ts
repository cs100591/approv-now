// Supabase Edge Function: Email Notifications
// This function handles sending email notifications for the Approve Now app

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const { type, data } = await req.json()

    // Get SendGrid API key from environment
    const sendGridApiKey = Deno.env.get('SENDGRID_API_KEY')
    
    if (!sendGridApiKey) {
      console.log('SendGrid API key not configured - email notifications disabled')
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: 'Email notifications are not configured' 
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    let emailResponse

    switch (type) {
      case 'invitation':
        emailResponse = await sendInvitationEmail(sendGridApiKey, data)
        break
      case 'approval_request':
        emailResponse = await sendApprovalRequestEmail(sendGridApiKey, data)
        break
      case 'approval_completed':
        emailResponse = await sendApprovalCompletedEmail(sendGridApiKey, data)
        break
      case 'request_rejected':
        emailResponse = await sendRejectionEmail(sendGridApiKey, data)
        break
      default:
        throw new Error(`Unknown email type: ${type}`)
    }

    return new Response(
      JSON.stringify({ success: true, data: emailResponse }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error in email-notifications function:', error)
    
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})

async function sendInvitationEmail(apiKey: string, data: any) {
  const { email, workspaceName, inviterName, inviteToken } = data

  const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      personalizations: [
        {
          to: [{ email }],
          dynamic_template_data: {
            workspaceName,
            inviterName,
            inviteLink: `${Deno.env.get('APP_URL')}/invite?token=${inviteToken}`,
          },
        },
      ],
      from: { email: Deno.env.get('EMAIL_FROM') || 'noreply@approvenow.app' },
      template_id: Deno.env.get('SENDGRID_INVITATION_TEMPLATE_ID'),
    }),
  })

  if (!response.ok) {
    throw new Error(`SendGrid API error: ${response.statusText}`)
  }

  return { type: 'invitation', email }
}

async function sendApprovalRequestEmail(apiKey: string, data: any) {
  const { email, requestorName, templateName, workspaceName } = data

  const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      personalizations: [
        {
          to: [{ email }],
          dynamic_template_data: {
            requestorName,
            templateName,
            workspaceName,
          },
        },
      ],
      from: { email: Deno.env.get('EMAIL_FROM') || 'noreply@approvenow.app' },
      template_id: Deno.env.get('SENDGRID_APPROVAL_TEMPLATE_ID'),
    }),
  })

  if (!response.ok) {
    throw new Error(`SendGrid API error: ${response.statusText}`)
  }

  return { type: 'approval_request', email }
}

async function sendApprovalCompletedEmail(apiKey: string, data: any) {
  const { email, templateName, workspaceName } = data

  const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      personalizations: [
        {
          to: [{ email }],
          dynamic_template_data: {
            templateName,
            workspaceName,
          },
        },
      ],
      from: { email: Deno.env.get('EMAIL_FROM') || 'noreply@approvenow.app' },
      template_id: Deno.env.get('SENDGRID_COMPLETED_TEMPLATE_ID'),
    }),
  })

  if (!response.ok) {
    throw new Error(`SendGrid API error: ${response.statusText}`)
  }

  return { type: 'approval_completed', email }
}

async function sendRejectionEmail(apiKey: string, data: any) {
  const { email, templateName, workspaceName, reason } = data

  const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      personalizations: [
        {
          to: [{ email }],
          dynamic_template_data: {
            templateName,
            workspaceName,
            reason,
          },
        },
      ],
      from: { email: Deno.env.get('EMAIL_FROM') || 'noreply@approvenow.app' },
      template_id: Deno.env.get('SENDGRID_REJECTION_TEMPLATE_ID'),
    }),
  })

  if (!response.ok) {
    throw new Error(`SendGrid API error: ${response.statusText}`)
  }

  return { type: 'request_rejected', email }
}
