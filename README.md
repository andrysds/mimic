# Mimic
API Mock

# How to use?
Create your mock response in folder responses. You should be able to see existing examples there. For example if you want to mock `/example/example` route, you create your mock response like [this](https://github.com/andrysds/mimic/blob/master/responses/example/example.json)

# How to run?
```sh
ruby app.rb
```

or like this if you want to specify the port

```sh
PORT=8080 ruby app.rb
```

# How to access?
```sh
curl localhost:4567/example/example
```
