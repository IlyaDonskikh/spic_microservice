# Launch

1. Set environment variables (see `.env.sample`).
2. Run `bundle exec karafka server`.
3. Run `bundle exec sidekiq -q default -r ./karafka.rb`.
