# Rumbl.Umbrella

## Initial setup
Before running the setup make sure to have a `apps/rumbl/config/dev.secret.exs` file with the Wolfram Alpha API
credentials.

### Get dependencies:
1. Download Elixir dependencies
```
mix deps.get
```
2. Download JS dependencies in the `rumbl_web` app.
```
cd apps/rumbl_web/assets/
npm install
```

### Setup the database
3. Go up to the the `apps` directory and now get into the `rumbl` app directory. Once there, create the DB.
```
cd ../../rumbl/
mix ecto.create
```
4. Run the migrations and additional DB seeds.
```
mix ecto.setup    # This runs ecto.create, ecto.migrate and run priv/repo/seeds.exs
mix run priv/repo/backend_seeds.exs   # This seed has to be run manually; it creates the Wolfram user
```


## Running the app
Now that the app is setup and the DB is ready, you can run the Umbrella application or one of the child apps separately.
For running the whole app, move to the umbrella app's root, and start the Phoenix server:
```
mix phx.server
```
Go to port 4000 or whatever other port the app is setup to run into when in the development environment.
You can also run the app in interactive mode with IEx, using:
```
iex -S mix phx.server
```


## Running tests
To run the all the tests, execute
```
mix test
```