import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    const oneSignalAppId = Deno.env.get('ONESIGNAL_APP_ID')
    const oneSignalRestApiKey = Deno.env.get('ONESIGNAL_REST_API_KEY')

    // We explicitly use the SERVICE_ROLE_KEY so we bypass RLS and can fetch ANY user's push token.
    const supabase = createClient(supabaseUrl!, supabaseServiceKey!)

    let payload;
    try {
      payload = await req.json()
    } catch (e) {
      return new Response(
        JSON.stringify({ error: 'Failed to parse JSON body' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!payload?.userId || !payload?.title || !payload?.body) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields (userId, title, body)' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { userId, title, body, data = {} } = payload

    const { data: playerData } = await supabase
      .from('user_push_tokens')
      .select('player_id')
      .eq('user_id', userId)
      .eq('enabled', true)

    const subscriptionIds = (playerData ?? []).map((p: any) => p.player_id)

    const oneSignalUrl = 'https://onesignal.com/api/v1/notifications'
    const oneSignalPayload: any = {
      app_id: oneSignalAppId,
      headings: { en: title },
      contents: { en: body },
      data: data,
      ios_badgeType: 'Increase',
      ios_badgeCount: 1,
      priority: 10,
    }

    if (subscriptionIds.length > 0) {
      oneSignalPayload.include_subscription_ids = subscriptionIds
    } else {
      oneSignalPayload.include_aliases = { external_id: [userId] }
      oneSignalPayload.target_channel = 'push'
    }

    const oneSignalResponse = await fetch(oneSignalUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${oneSignalRestApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(oneSignalPayload),
    })

    const errorText = await oneSignalResponse.text()

    let resjson = {}
    try { resjson = JSON.parse(errorText) } catch (e) { }

    return new Response(
      JSON.stringify({
        success: oneSignalResponse.ok,
        message: 'Notification sent',
        result: resjson
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error: any) {
    return new Response(
      JSON.stringify({ success: false, error: String(error) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
