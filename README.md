# Lobanov [![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/lobanov`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lobanov', github: 'spajic/lobanov', tag: 'v0.0.0' # see Changelog.md
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lobanov

## Why Lobanov
There is a couple of similar projects (see the section and comparison below)

What I see as key strong / unique points of Lobanov:
- Easy to introduce to large codebase. You just add `:lobanov` tag to one spec.
When another.
So you can start small. You can generate schema only for what you want.
- You can run just one spec to update the schema. No need to run all specs.
- It allows to modify schema by hand and keep the changes.
- No DSL. Nothing new to learn, just add `:lobanov` tag and you are all set.
- Schema is generated automatically, you can tweak it if you want.
- Ability to generate a directory with convenient structure for manual work
with openapi-schema. And automatically bundle it to single file for export.
- It validates the API response in your spec against stored schema. 
So you can prevent accidental breaking of contract.
- It automatically and consistently generates schema 
with Convention over Configuration approach. 
This leads to a clean and structured result, 
that would be difficult to do by hand, even having developer documentation
on how-to write openapi specs.
- It works both with controller specs and request specs.
- (We plan to) support sinatra to be able to use lobanov with microservices.
- Support for rails 6.1 and (we plan to) rails 7.0

## Alternatives and related projects

### expego/rspec-openapi

https://github.com/exoego/rspec-openapi

Overall very nice project, it has many things done just right.

Key differences:
- it does not validate spec to conform with schema, it always updates schema
- it relies on running all specs to generate a single large openapi bundle
- it suppose to exclude specs from schema generation with `openapi: false`, rather than include with `:lobanov`
- it does not generate structured representation with multiple files, just one huge bundle

Questions:
- does it really work with controller specs? 

Some points:
- Generate OpenAPI schema from RSpec request specs (there is a setting RSpec::OpenAPI.example_types)
- stars: 273
- Generate openapi from specs without requiring any special DSL
- Keeps manual modifications on merging automated changes!
- Usage: `OPENAPI=1 bundle exec rspec`
- For specs `type: :request`
- Support generating multiple schema files splitting by spec file prefix (and maybe by other logic based on example's properties)
- Support refs and automatically refactors to components given ref to registered component
- You can exclude spec from generation with `openapi: false` tag (`lobanov` goes the opposite way)
- some attributes can be overwritten via RSpec metadata options (`lobanov` has zero DSL)
- has very reasonable Settings to configure all aspects of openapi index and other configurables
- does not support `required`: https://github.com/exoego/rspec-openapi/issues/89
- relies on run of all specs and deletes parts of index.yaml that was not covered by tests
- *does not validate schema but rather updates it with merge*
- generates one large file, not a folder with a multi-file structure


### rswag/rswag
https://github.com/rswag/rswag

For me the showstopper here is that you have to effectively *write spec by hand, but in DSL*

For me it is too tedious. And than I tried to work with rswag I very soon get stuck with that DSL - I didn't understand how can I achieve the required result through the DSL.

Questions:
- does it support controller specs?

Some points:
- stars: 1600
- it validates responses to conform with the schema
- supports request-specs
- heavy usage of Swagger-based DSL
- usage: write DSL to describe your API operations -> (it automatically run tests) -> run a rake task to generate swagger files
- effectively you have to *write open-api schema by hand* in the form of DSL

### rspec-rails-swagger

TODO

### rspec_api_documentation

### r7kamura/autodoc
That was the inspiration for rspec-openapi

### lurker
TODO

## Usage

### Что должен уметь Lobanov: checklist

#### Now

- [ ] надо подумать, как бы обозначать обязательность для query-параметров (возможно они все *не обязательные* по дефолту)
- [ ] Надо договориться, как работать с ошибками
  - [ ] тело ответа пустое, или {}
  - [ ] стоит ли свести все ошибки к единому типу (code, message, content)?
- [ ] для GET сохранить path и схему Response в componets/responses
  - [x] GET /fruits,
  - [x] GET /fruits/:id,
  - [ ] GET /resources/:id/reviews
  - [ ] GET /resources/:id/reviews/:review_id
- [ ] ронять тест, если схема ответа изменилась
- [ ] для POST, PUT, DELETE важно сохранять схему параметров запроса (в components/params?)
  - [x] POST
  - [x] PUT
  - [x] DELETE
- [ ] генерировать схемы передаваемых параметров
  - [x] path params
  - [x] body params
  - [ ] query params - есть, но покрыть спеком
- [ ] требовать чтобы для examples все поля были заполнены (протестировать)

#### Later
- [ ] уметь работать с enums, когда поле может принимать известное множество значений
- [ ] (?) требовать стандартной схемы для успешного ответа POST, PUT, DELETE

#### Notes
- [ ] все поля, которые в lobanov-spec приходят в Response считаем обязательными и требуем чтобы было не пустое значение для example
- [ ] API подразумевается json, параметры либо в path, либо в query, либо в body в json
- [ ] В OpenApi предусмотрена наряду с components.schemas секция components.responses: for reusable responses, like 401 Unauthorized or 400 Bad Request, 404 Not Found.
- [ ] see https://swagger.io/docs/specification/components/
- [ ] https://swagger.io/docs/specification/describing-request-body/
  - в OpenAPI v2 было parameters in body, в v3 стало `requestBody`
- [ ] хорошо бы реюзать схему ресурса для show, index и create
- [ ] для ошибок можно завести стандартные общепринятые типы ответа, и контроллировать лобановым что схема действительно соблюдается


### Схема хранения

Вообще схемы хранения могут быть разные, но начнём с одной.

Пусть есть ресурс и вложенный ресурс, например пусть Фрукты и Отзывы на фрукты

И пусть ещё всё это в неймспейсе `wapi/`

- GET /fruits (index)
- GET /fruits/:id (show)
- POST /fruits (create)
- PUT /fruits/:id (update)
- DELETE /fruits/:id (destroy)

- GET /fruits/:id/reviews (index)
- POST /fruits/:id/reviews (create)
- GET /fruits/:id/reviews/:review_id (show)
- PUT /fruits/:id/reviews/:review_id (update)
- DELETE /fruits/:id/reviews/:review_id (destroy)

И может быть ещё что-то не по REST'у

- POST /fruits/:id/reviews/:review_id/upvote
- POST /fruits/:id/reviews/:review_id/downvote

При этом надо учесть, что один и тот же эндпоинт может возвращать ответы с разными статусами.

Как это всё будет храниться в нашей схеме

api-backend-specification

По идее внутри файла с описание path лежат разные HTTP statuses и verbs

Кажется единственный простой и понятный вариант - всегда называть сам файл path.yaml, а класть его в соответствии собственно с путём. Иначе возникают special-cases типа index.yaml / root.yaml - в зависимости от того, есть ли что-то внутри папки, или нет

index.yaml

```yaml
paths:
  "/fruits": # Здесь нужно совместить GET index и POST create
    "$ref": "./paths/fruits/path.yaml"
  "/fruits/{id}": # Здесь нужно как-то совместить GET show и DELETE destroy и PUT update
    "$ref": "./paths/fruits/[id]/path.yaml"
  "/fruits/{id}/reviews": # GET, POST
    "$ref": "./paths/fruits/[id]/reviews/path.yaml"
  "/fruits/{id}/reviews/{review_id}": # GET, PUT, DELETE
    "$ref": "./paths/fruits/[id]/reviews/[review_id]/path.yaml"
  "/fruits/{id}/reviews/{review_id}/upvote":
    "$ref": "./paths/fruits/[id]/reviews/[review_id]/upvote/path.yaml"
  "/fruits/{id}/reviews/{review_id}/downvote":
    "$ref": "./paths/fruits/[id]/reviews/[review_id]/downvote/path.yaml"
```

Внутри `paths/fruits/[id]/reviews/path.yaml`

Тут в принципе всё понятно, надо продумать

- как хранить компоненты
- как возвращать ошибки (ApiErrorResponse?)

Компоненты

```yaml
# успешные ответы сохраняем в components/responses
# формируем название как ResourсeNestedActionResponse.yaml
# Action - это название action'a контроллера, который обрабатывает запрос
- ./components/responses/FruitsIndexResponse.yaml
- ./components/responses/FruitsShowResponse.yaml
- ./components/responses/FruitsCreateResponse.yaml
- ./components/responses/FruitsReviewsDownvoteResponse.yaml

```

Это responses - это база, которую понятно как полностью автоматизировать и на которой мы будем дальше строить.

Для любых неуспешных ответов будем возвращать класс ErrorResponse.yaml (error_code, message, payload)

```yaml
- ./components/shared/ErrorResponse.yaml
- ./components/models/FruitModel.yaml # здесь то что возвращает FruitsShow и FruitsIndex
- ./components/params/PaginationParams.yaml # здесь например общие повторящиеся описания параметров типа пагинации
```

Что делать с тем, что index по идее возвращает массив моделей из Show?
Если это реально будет соблюдаться, можно сделать генерацию моделей и подстановку в постпроцессинге.

Но сейчас это не всегда так на самом деле.
В индексе может быть, например, объект, где одно поле items, а другие например про пагинацию или какие-то доп поля.

Если у нас будет какое-то соглашение, то можно будет тоже это как-то автоматизировать, завернуть во что-то типа IndexWithPagination. Но наверно лучше привести к тому, чтобы index возвращал только коллекцию.

Возможно кстати для POST, PUT, DELETE даже в случае успеха схема компонента чтобы была стандартная, типа SuccessfulCreate, SuccessfulUpdate, SuccessfulDelete или т.п.

Когда речь идёт про POST, PUT намного важнее схема параметров, в т.ч. в body

При DELETE чаще особо ничего не важно наверно, удалили по id успешно, да и всё.

_Ну и всегда схему можно доработать руками_ - `Lobanov` же не будет её автоматически переписывать, но сможет контроллировать корректность


```yaml
get:
  summary: Get fruit reviews
  responses:
    200:
      description: OK
      content:
        application/json:
          schema:
            "$ref": "../../../components/Fruits/item.yaml"
put:
  summary: Edit deal
  parameters:
    - in: path
      name: id
      schema:
        type: string
      required: true
      example: "1"
  responses:
    200:
      description: OK
      content:
        application/json:
          schema:
            "$ref": "../../../components/Deals/Update/200.yaml"
    422:
      description: Unprocessable Entity
      content:
        application/json:
          schema:
            "$ref": "../../../components/Deals/Update/422.yaml"


```




### Configuration

В config/initializers/lobanov.rb

```ruby
Lobanov.configure do |config|
  config.specification_folder = 'fffuuu'
end
```

## Development

### Publishing of new versions
For now we just use git tags like v0.1.1 and refer to them from Gemfile

We do not push to Rubygems now. 

### Specs

#### Cucumber

First of all, testing for lobanov is a bit intricated.

What we need to test is something like

```
If I have some rails app and some specs and some stored openapi schema
When I run rspec tests
What will be results of the specs run?
And how files will change?
```

To test this behavior we use `Cucumber` scenarios.

To run these scenarios use `bundle exec appraisal rails-61 cucumber`

#### Appraisal
Even more, we have to test lobanov with different versions of Rails.

Because the internals on which we rely to hook into rails routes may change.

To achieve this we use [Appraisal gem](https://github.com/thoughtbot/appraisal)

For now we only have rails-61 example app, but we have plans to support rails-7.

Execute `bundle exec appraisal install` to setup appraisal.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spajic/lobanov.
