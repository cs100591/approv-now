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

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  const supabase = createClient(supabaseUrl!, supabaseServiceKey!)

  const { data: reqs } = await supabase.from('requests')
    .select('id, status, current_approver_ids, template_name, submitted_by, created_at')
    .order('created_at', { ascending: false })
    .limit(5)

  return new Response(JSON.stringify({ reqs }), { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
})
