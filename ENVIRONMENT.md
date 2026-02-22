# Environment Configuration

This project supports configuration via environment variables for sensitive data like API keys.

## Supabase Configuration

The app can load Supabase credentials from environment variables:

- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anonymous/public key

## Usage

### Development (with default values)
```bash
flutter run
```

### Development (with custom values)
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Production/Release
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### VS Code Configuration

Add to `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Approve Now",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://your-project.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key"
      ]
    }
  ]
}
```

## Security Notes

- Never commit production API keys to version control
- Use environment variables for CI/CD pipelines
- Rotate keys regularly
- Monitor API usage for suspicious activity

## Fallback Values

For development convenience, the app includes fallback values in `lib/core/config/supabase_config.dart`. These should only be used for local development and never in production.
