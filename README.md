## README

Lookbox app helps you to store, sort out, compare and combine your images, photos, etc..
Visit and try https://lookbox.herokuapp.com

### Technical stack

* ruby version: 2.3.8
* rails version: 4.2.8

* database: mysql/postgresql
* authorization: omniauth, devise
* api: grape

* image store(CDN): local/cloudinary
* image processing: carrierwave

* front-end frameworks/libs: react.js/jquery
* frontend preprocessors: coffee, haml, sass
* css: bootsrap

* delayed jobs: sidekiq
* debugging: pry-byebug
* errors monitoring: bugsnag

* build, deploy: circleci
* docker container: lookbox(not published)

* tests unit/integration: minitest/capybara

* application platform: heroku
* site url: lookbox.herokuapp.com
* project store github/bitbucket: github.com/normatopal/lookbox

### Rake tasks
rake settings:add_locales
rake settings:locales_visibility LOCALES='es,ru' VISIBLE=false

Keeping secrets: secret_tokens.yml
USE_CLOUDINARY: "true"  - use cloudinary instead of local image store

### Api examples

lookbox.herokuapp.com/api/v1/categories?access_token=<your access token from settings>
lookbox.herokuapp.com/api/v1/pictures?access_token=<your access token>
lookbox.herokuapp.com/api/v1/looks?access_token=<your access token>

### Use Case Diagram

![Use Case](public/images/usecase_diagram.jpg)

### Classes Diagram
![Classes](public/images/classes_diagram.jpg)


