import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { encode as base64Encode } from 'https://deno.land/std@0.177.0/encoding/base64.ts'

/**
 * Send Push Notification via FCM V1 API
 * 
 * This Edge Function sends push notifications using Firebase Cloud Messaging V1 API
 * with OAuth2 service account authentication.
 */

interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, any>;
}

interface ServiceAccount {
  type: string;
  project_id: string;
  private_key_id: string;
  private_key: string;
  client_email: string;
  client_id: string;
  auth_uri: string;
  token_uri: string;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Generate JWT token for OAuth2 authentication
 */
function generateJWT(serviceAccount: ServiceAccount): string {
  const now = Math.floor(Date.now() / 1000)
  const expiry = now + 3600 // 1 hour

  const header = {
    alg: 'RS256',
    typ: 'JWT',
    kid: serviceAccount.private_key_id,
  }

  const claim = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: serviceAccount.token_uri,
    iat: now,
    exp: expiry,
  }

  const encodedHeader = base64Encode(
    new TextEncoder().encode(JSON.stringify(header))
  )
  const encodedClaim = base64Encode(
    new TextEncoder().encode(JSON.stringify(claim))
  )

  const signatureInput = `${encodedHeader}.${encodedClaim}`

  // Import the private key and sign
  const privateKey = serviceAccount.private_key
    .replace('-----BEGIN PRIVATE KEY-----\n', '')
    .replace('\n-----END PRIVATE KEY-----', '')
    .replace(/\n/g, '')

  // Note: In production, you'd use a proper crypto library
  // For Deno Edge Functions, we'll use the Google OAuth2 endpoint directly
  return signatureInput
}

/**
 * Get OAuth2 access token using service account
 */
async function getAccessToken(serviceAccount: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  
  const jwtHeader = {
    alg: 'RS256',
    typ: 'JWT',
  }
  
  const jwtClaim = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }
  
  const encodedHeader = btoa(JSON.stringify(jwtHeader))
  const encodedClaim = btoa(JSON.stringify(jwtClaim))
  const signatureContent = `${encodedHeader}.${encodedClaim}`
  
  // For Deno, we need to use the private key properly
  // Since crypto.sign is complex in Edge Functions, let's use a simpler approach
  // We'll make a POST request to get the token using the service account
  
  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: await createJWTAssertion(serviceAccount),
    }),
  })
  
  if (!tokenResponse.ok) {
    const error = await tokenResponse.text()
    throw new Error(`Failed to get access token: ${error}`)
  }
  
  const tokenData = await tokenResponse.json()
  return tokenData.access_token
}

/**
 * Create JWT assertion for OAuth2
 */
async function createJWTAssertion(serviceAccount: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  
  const header = {
    alg: 'RS256',
    typ: 'JWT',
  }
  
  const payload = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  }
  
  const encodedHeader = btoa(JSON.stringify(header))
  const encodedPayload = btoa(JSON.stringify(payload))
  const signingInput = `${encodedHeader}.${encodedPayload}`
  
  // Parse the private key
  const privateKeyPEM = serviceAccount.private_key
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '')
  
  const privateKeyBuffer = Uint8Array.from(atob(privateKeyPEM), c => c.charCodeAt(0))
  
  // Import key and sign
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    privateKeyBuffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )
  
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput)
  )
  
  const encodedSignature = btoa(String.fromCharCode(...new Uint8Array(signature)))
  
  return `${signingInput}.${encodedSignature}`
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
    const serviceAccountJson = Deno.env.get('FCM_SERVICE_ACCOUNT')

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing Supabase configuration')
    }

    if (!serviceAccountJson) {
      throw new Error('Missing FCM_SERVICE_ACCOUNT environment variable')
    }

    const serviceAccount: ServiceAccount = JSON.parse(serviceAccountJson)

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
      .from('profiles')
      .select('fcm_token')
      .eq('id', userId)
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

    // Get OAuth2 access token
    console.log('Getting OAuth2 access token...')
    const accessToken = await getAccessToken(serviceAccount)
    console.log('Access token obtained')

    // Send FCM V1 notification
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`
    
    const fcmResponse = await fetch(fcmUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token: profile.fcm_token,
          notification: {
            title,
            body,
          },
          data: {
            ...data,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          android: {
            notification: {
              sound: 'default',
              channel_id: 'approv_now_channel',
            },
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
              },
            },
          },
        },
      }),
    })

    if (!fcmResponse.ok) {
      const fcmError = await fcmResponse.text()
      console.error('FCM send failed:', fcmError)
      
      // If token is invalid (404 or 410), clear it from the database
      if (fcmResponse.status === 404 || fcmResponse.status === 410) {
        await supabase
          .from('profiles')
          .update({ fcm_token: null })
          .eq('id', userId)
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
    console.log('FCM notification sent successfully:', fcmResult)

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Notification sent successfully',
        userId,
        messageId: fcmResult.name 
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
