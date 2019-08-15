# Spic Microservice

Spic helps to create images based on the content (which is great for social media sharing), has unlimited potential for horizontal scalability and great workflow.

<img width="600" src="https://doniv-shared-pictures.s3.eu-central-1.amazonaws.com/spic/spic_facebook_sample.jpg"/>

## Basics

The interaction with the Spic is quite simple and at the same time very efficient: you produce data to the Kafka stream like a making simple request and consume the result when needed.

*If you're not familiar with Kafka, I advised you to take a short break here. Watch the [youtube video](https://www.youtube.com/watch?time_continue=1&v=Rzl4O1oaVy8), check `karafka` gem and come back with new powerfull knowledge.*

And now that we understand each other very well, it's time to tell you about the reasons for developing Spic and the principle of its operation.

## The Issue

Social media content sharing is a powerful tool for interacting with clients. Everything is important here: the title, the text, but the most important thing is the picture. And it would be a good solution to create attractive images based on the content automatically.

But in the architecture of such a module you may face the **following problems**:

1. Increasing dependencies within the main application
2. Difficulty of scaling

Both problems are solved by transfer of the module to the microservice architecture and its implementation through Kafka streams, which provides horizontal scalability.

## Spic Workflow

So, what happens after the microservice receives a message about creating a new image and before returning the answer? The easiest way to find out is to look through the example.

Firstly, Spic consumer `app/consumer/images_queuing_consumer.rb` receive JSON message from `spic_images_queuing` topic and pass it to sidekiq background worker.

```ruby
{
  "template_body" => { "text" => "I love microservices", "background_url" => "..." } # Hash
  "project" => "test_buddy", # String
  "template" => "simple", # String
  "sharing_type" => "facebook", # String
  "resource_type" => "test", # String
  "resource_id" => "1", # String
}
```

It's pretty easy to track that the information from the worker gets into the `app/interactors/draw_cover.rb` interactor. It is there that the image is generated and stored in the remote storage if validation is successful. As well the interactor produce message to `spic_images_tracking` topic by responder `app/responders/images_traking_responder.rb`.

```ruby
{
  "file_url" => "https://.../uploads/test_buddy/simple/test/1/facebook.jpg",
  "project" => "test_buddy",
  "template" => "simple",
  "resource_id" => "1",
  "resource_type" => "test",
  "sharing_type" => "facebook"
}

```

That's it. You can handle the information from the topic as you wish.

<img width="600" src="https://doniv-shared-pictures.s3.eu-central-1.amazonaws.com/spic/spic_i_love_microservices_facebook.jpg"/>

But what to do if you have to create tons of images. This is the easiest part, all you need is run a few microservices that will automatically share the work between them.

#### Templates

All images for the README were created using Spic. As you may have noticed, each of them represents a different template, and this is one of the coolest things in this microservice - **you can use Spic to manage different projects and data sets**.

But before you start creating your own great templates, you need to know one thing: the `imgkit` and `wkhtmltoimage-binary` gems are used to generate the image, which means that you may face a lack of support for some CSS features.

So, be careful, test your templates before go to production and the quality will be awesome!

## Configuration

Before you run Spic you need to be informed about some required and optional environment variables (ENV).

#### Required parameters

* `KAFKA_CLIENT_ID` - name of the microservise.
* `STORAGE_TYPE` - set `fog` for remote and `file` for local storage.
* `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_REGION`, `S3_BUCKET` - parameters required for access to remote S3 storage.
* `KAFKA_SEED_BROKERS` - address of Kafka brokers. To specify several brokers, you can use a comma (without spaces between addresses).

#### Optional parameters

* `KAFKA_TRUSTED_CERT`, `KAFKA_CLIENT_CERT`, `KAFKA_CLIENT_CERT_KEY` - The parameters are required to connect the Kafka via a certificate. Read more about this in the Deploy section.
* `BACKGROUND_URL_SAMPLE` - address to the file used in the tests as the background image of templates.

**Additional information**

For setting of development and test environments Spic uses a gem `dotenv`.

## Testing

Spic uses `rspec` as the main testing tool.

Run tests: `bundle exec rspec`. More information about the testing process is available in the `./spec` folder.

## Deploy

All you need is run karafka server and sidekiq.

Karafka: https://github.com/karafka/karafka/wiki/Deployment
Sidekiq: https://github.com/mperham/sidekiq/wiki/Deployment

**Important note for Heroku deployment:** It is recommended to run Spic on [Heroku-16](https://devcenter.heroku.com/articles/stack), because Heroku-18 does not support the `wkhtmltoimage` library (at the time of testing).

## Conclusion

Here we are.

However, Spic is not perfect, but always ready to get better. And if you find a way to improve the quality of the processes, don't forget to report it.

Thank you for your attention 🤖

