import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

/**
 * Send Push Notification via FCM
 * 
 * This Edge Function sends push notifications to users via Firebase Cloud Messaging.
 * It reads the user's FCM token from their profile and sends the notification.
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
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get environment variables
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing Supabase configuration')
    }

    if (!fcmServerKey) {
      throw new Error('Missing FCM_SERVER_KEY environment variable')
    }

    // Parse request body
    const payload: NotificationPayload = await req.json()
    const { userId, title, body, data = {} } = payload

    if (!userId || !title || !body) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: userId, title, body' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Get user's FCM token from their profile
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('fcm_token')
      .eq('user_id', userId)
      .single()

    if (profileError) {
      console.error('Error fetching user profile:', profileError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch user profile' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!profile?.fcm_token) {
      console.log(`No FCM token found for user ${userId}`)
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: 'User has no FCM token registered',
          userId 
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Send FCM notification
    const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Authorization': `key=${fcmServerKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        to: profile.fcm_token,
        notification: {
          title,
          body,
          sound: 'default',
          badge: '1',
        },
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        priority: 'high',
        content_available: true,
      }),
    })

    if (!fcmResponse.ok) {
      const fcmError = await fcmResponse.text()
      console.error('FCM send failed:', fcmError)
      
      // If token is invalid, clear it from the database
      if (fcmResponse.status === 404) {
        await supabase
          .from('user_profiles')
          .update({ fcm_token: null })
          .eq('user_id', userId)
        console.log(`Cleared invalid FCM token for user ${userId}`)
      }

      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'FCM send failed',
          details: fcmError 
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const fcmResult = await fcmResponse.json()

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Notification sent successfully',
        userId,
        fcmResult 
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error in send-push-notification function:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: 'Internal server error',
        details: error.message 
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
