# Aire

This is an example Rails application that uses ActiveInteraction to handle the
business logic. For the most part, [the documentation][] covers everything that
you need to know. That being said, there are a few gotchas:

-   Depending on how you name your interactions, you may need to configure the
    autoload paths. This application does not namespace interactions, so they
    have names like `CreateThing`. But the files are arranged into directories,
    like `things/create_thing.rb`. So [the application][] has to add all of the
    interaction directories to the autoload path.

    If you don't want to bother with all that, you can do one of two things:

    1.  Throw all of your interactions into one directory (`app/interactions`).
        This will probably get out of control quickly, but it should work
        without doing any extra work.

    2.  Namespace all of your interactions. This means that instead of
        `CreateThing`, you'll have `Things::Create` (or `Things::CreateThing`).
        This will let Rails autoload them without any additional configuration.

-   If you want to use an interaction as a form object, you need to define the
    `#to_model` method. For creating objects, you need to return an instance of
    the object you are creating. See [`CreateThing`][] for an example. For
    updating objects, you need to return the actual object you are updating.
    See [`UpdateThing`][] for an example.

[the documentation]: ../README.md#rails
[the application]: config/application.rb#L15
[`creatething`]: app/interactions/things/create_thing.rb#L12-15
[`updatething`]: app/interactions/things/update_thing.rb#L16-19
