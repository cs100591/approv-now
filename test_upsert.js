const { createClient } = require('@supabase/supabase-js')

const url = 'https://poaontiyougqfzmzxerf.supabase.co'
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvYW9udGl5b3VncWZ6bXp4ZXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2MDQ2ODQsImV4cCI6MjA4NzE4MDY4NH0.o0xQNrVDzly3B2rvbE5y12Sazd6HVct148Z-mJRKn8M'

const supabase = createClient(url, key)

async function test() {
    const { data, error } = await supabase
        .from('user_push_tokens')
        .upsert({
            user_id: '123e4567-e89b-12d3-a456-426614174000',
            player_id: 'test_token',
            platform: 'ios',
            enabled: true
        }, { onConflict: 'user_id,player_id' })

    console.log('Error from upsert with conflict id:', error)

    const { data: data2, error: error2 } = await supabase
        .from('user_push_tokens')
        .insert({
            user_id: '123e4567-e89b-12d3-a456-426614174000',
            player_id: 'test_token',
            platform: 'ios',
            enabled: true
        })
    console.log('Error from pure insert:', error2)
}

test()
