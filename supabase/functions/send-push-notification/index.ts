import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

/**
 * Send Push Notification via OneSignal
 * 
 * OneSignal is more reliable than FCM/Pusher for iOS
 * Free tier: 10k subscribers, unlimited notifications
 */

interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, any>;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  console.log('========================================')
  console.log('ONESIGNAL: Starting push notification')
  console.log('========================================')

  try {
    // Get environment variables
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    const oneSignalAppId = Deno.env.get('ONESIGNAL_APP_ID')
    const oneSignalRestApiKey = Deno.env.get('ONESIGNAL_REST_API_KEY')

    console.log('Environment check:')
    console.log('- SUPABASE_URL:', supabaseUrl ? 'Set' : 'MISSING')
    console.log('- ONESIGNAL_APP_ID:', oneSignalAppId ? 'Set' : 'MISSING')
    console.log('- ONESIGNAL_REST_API_KEY:', oneSignalRestApiKey ? 'Set' : 'MISSING')

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing Supabase configuration')
    }

    if (!oneSignalAppId || !oneSignalRestApiKey) {
      throw new Error('Missing OneSignal configuration. Please set ONESIGNAL_APP_ID and ONESIGNAL_REST_API_KEY in Supabase Secrets.')
    }

    // Parse request
    const payload: NotificationPayload = await req.json()
    const { userId, title, body, data = {} } = payload

    console.log('Request:', { userId, title, body: body?.substring(0, 50) })

    if (!userId || !title || !body) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get user's OneSignal Player IDs from database
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const { data: playerData, error: playerError } = await supabase
      .from('user_push_tokens')
      .select('player_id')
      .eq('user_id', userId)
      .eq('enabled', true)

    if (playerError) {
      console.error('Error fetching player IDs:', playerError)
      throw new Error('Failed to fetch user push tokens')
    }

    if (!playerData || playerData.length === 0) {
      console.log('No push tokens found for user:', userId)
      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'No push tokens found for user',
          sent: false 
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const playerIds = playerData.map(p => p.player_id)
    console.log('Found Player IDs:', playerIds)

    // Send notification via OneSignal
    const oneSignalUrl = 'https://onesignal.com/api/v1/notifications'
    
    const oneSignalPayload = {
      app_id: oneSignalAppId,
      include_player_ids: playerIds,
      headings: { en: title },
      contents: { en: body },
      data: data,
      ios_badgeType: 'Increase',
      ios_badgeCount: 1,
      priority: 10,
    }

    console.log('Sending to OneSignal:', oneSignalUrl)
    console.log('Payload:', JSON.stringify(oneSignalPayload, null, 2))

    const oneSignalResponse = await fetch(oneSignalUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${oneSignalRestApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(oneSignalPayload),
    })

    console.log('OneSignal Response Status:', oneSignalResponse.status)

    if (!oneSignalResponse.ok) {
      const errorText = await oneSignalResponse.text()
      console.error('OneSignal Error:', errorText)
      throw new Error(`OneSignal failed: ${errorText}`)
    }

    const result = await oneSignalResponse.json()
    console.log('OneSignal Success:', result)

    // Log analytics (async, don't block response)
    try {
      await supabase.from('notification_logs').insert({
        user_id: userId,
        type: 'push',
        title,
        body,
        status: 'sent',
        provider: 'onesignal',
        recipients: result.recipients || 0,
        response_id: result.id,
      })
    } catch (logError) {
      console.error('Failed to log notification:', logError)
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Notification sent via OneSignal',
        recipients: result.recipients,
        notificationId: result.id 
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('========================================')
    console.error('ONESIGNAL ERROR:', error)
    console.error('========================================')
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
