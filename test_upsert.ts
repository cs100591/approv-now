import { createClient } from 'npm:@supabase/supabase-js@2'

// Using the anon key found in supabase_config.dart
const url = 'https://poaontiyougqfzmzxerf.supabase.co'
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvYW9udGl5b3VncWZ6bXp4ZXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2MDQ2ODQsImV4cCI6MjA4NzE4MDY4NH0.o0xQNrVDzly3B2rvbE5y12Sazd6HVct148Z-mJRKn8M'

const supabase = createClient(url, key)

async function test() {
    // First login using an existing user? Wait, we don't know any user's credentials.
    // Instead, just try to upsert with some random uuid and see what the error says.
    const { data, error } = await supabase
        .from('user_push_tokens')
        .upsert({
            user_id: '123e4567-e89b-12d3-a456-426614174000',
            player_id: 'test_token',
            platform: 'ios',
            enabled: true
        }, { onConflict: 'user_id,player_id' })

    console.log('Result:', { data, error })
}

test()
