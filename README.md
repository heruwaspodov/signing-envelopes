# 👩🏻‍💼 Mekari Sign (Backend)


## 📰 Table of Contents

| Content                                                              |
|----------------------------------------------------------------------|
| [Table of Contents](#-table-of-contents)                             |
| [Requirements](#-requirements)                                       |
| [How to: Clone Repository](#-clone-repository)                       |
| [How to: Setup Environment Variables](#-setup-environment-variables) |
| [How to: Setup Project](#-setup-project)                             |
| [API Documentations](#-documentations)                               |

## 🛠️ Requirements

1. Git
2. Ruby (v3.0.7)
3. Gem
4. Bundle
5. PostgreSQL
6. Imagemagick

## 🚿 How to

### 🏹 Clone Repository

1. Make sure you have Git installed on your machine.
   ```bash
   $ git --version # git version 2.33.1
   ```
2. Run the following command.
   ```bash
   $ git clone git@bitbucket.org:jurnal/msign-backend.git # using SSH
   # or
   $ git clone https://username@bitbucket.org/jurnal/msign-backend.git # using HTTPS
   ```

### 🌏 Setup Environment Variables

1. Add the following lines to your `.bashrc`, `.zshrc`, or any others shell configuration file for your machine setup.
   ```bash
   # Shell configuration file, e.g., .bashrc
   export RAILS_ENV=production
   export SECRET_KEY_BASE=your_secret_key
   export MEKARI_SIGN_DATABASE_HOST=localhost
   export MEKARI_SIGN_DATABASE_PORT=5432
   export MEKARI_SIGN_DATABASE_USERNAME=postgres
   export MEKARI_SIGN_DATABASE_PASSWORD=postgres
   export CLOUDHSM_PROVIDER=aliyun
   export CLOUDHSM_REGION=ap-southeast-5
   export CLOUDHSM_CLUSTER_REGION=ap-southeast-5
   export CLOUDHSM_ALI_DIR=/opt/hsm/etc
   export CLOUDHSM_ALI_CLUSTER_DIR=/opt/hsm/etc
   export CLOUDHSM_ALI_CUSTOMERCA_DIR=/opt/hsm/etc/customerCA.crt
   export CLOUDHSM_ALI_PRIVATEKEY_DIR=/opt/hsm/etc/app-private-key.pem
   export CLOUDHSM_ALI_GLOBALSIGN_CERT=/opt/hsm/etc/globalsign-cert.crt
   export CLOUDHSM_ALI_GLOBALSIGN_INTERMEDIATE_1=/opt/hsm/etc/globalsign-intermediate1.crt
   export CLOUDHSM_ALI_GLOBALSIGN_INTERMEDIATE_2=/opt/hsm/etc/globalsign-intermediate2.crt
   export CERT_URL_ROOT=https://secure.globalsign.net/cacert/root-r6.crt
   export CERT_URL_TSA=https://secure.globalsign.com/cacert/gstsasha2g4.crt
   export TSA_SERVER_URL=http://your.tsa.url
   ```

### 🏦 Setup Project

#### Installing Ruby using [mise](https://mise.jdx.dev/)

```bash
# @see https://github.com/jdx/mise/discussions/4454 -> https://github.com/rvm/rvm/issues/5507#issuecomment-2879664534
MISE_RUBY_APPLY_PATCHES=https://github.com/ruby/ruby/commit/1dfe75b0beb7171b8154ff0856d5149be0207724.patch \
MISE_RUBY_BUILD_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)" \
mise use ruby@3.0.7
```

#### Installing Ruby using [rvm](https://rvm.io/)

```bash
# https://github.com/rvm/rvm/issues/5507#issuecomment-2411632552
curl -sSL https://github.com/ruby/ruby/commit/1dfe75b0beb7171b8154ff0856d5149be0207724.patch -o ruby-307-fix.patch && rvm install 3.0.7 --patch ruby-307-fix.patch --with-openssl-dir=$(brew --prefix openssl@1.1) && rm ruby-307-fix.patch;
```

#### Make sure your bundler version is 2.3.6

```bash
gem install bundler -v 2.3.6
bundler -v # 2.3.6
```

1. Make sure you have [cloned the repository](#clone-repository).
2. Make sure you have [setup the environment variables](#setup-environment-variables).
3. Make sure you have all the [requirements](#requirements) installed on your machine.
   ```bash
   $ ruby --version # ruby 3.0.7p220 (2024-04-23 revision 724a071175) [arm64-darwin24]
   $ gem --version # 3.2.32
   $ bundle --version # Bundler version 2.3.6
   $ PostgreSQL --version # PostgreSQL Ver 12.8
   $ which postman # /usr/bin/postman
   $ docker --version # Docker version 20.10.9, build c2ea9bc90b
   $ docker-compose --version # Docker Compose version 2.0.1
   ```
4. Change your working directory into the project.
   ```bash
   $ cd msign-backend
   ```
5. Install the dependencies by running the following command.
   ```bash
   # Ask you peer to get the BUNDLE_GEMS__CONTRIBSYS__COM value
   $ bundle install
   ```
6. Create, migrate, and seeds the database by running the following command.
   ```bash
   $ bundle exec rails db:setup
   $ bundle exec rails db:seed
   ```

### Bundle Install Known Issues

#### `ruby-filemagic`

```bash
brew install libmagic
# @see https://gist.github.com/eparreno/1845561?permalink_comment_id=3813020#gistcomment-3813020
# install it by link to the homebrew libmagic, this issue usually happen on M series Macbook
gem install ruby-filemagic -v '0.7.2' --source 'https://rubygems.org/' -- --with-magic-include=/opt/homebrew/include --with-magic-lib=/opt/homebrew/lib/
# then run
bundle install
```

#### `nio4r`

```bash
# Install it by disabling the warning
# @see https://stackoverflow.com/a/78329687
gem install nio4r -v 2.5.8 -- --with-cflags="-Wno-incompatible-pointer-types"
# then run
bundle install
```

#### `rugged`

```bash
gem install rugged -v '1.0.1' -- --with-cflags="-Wno-incompatible-function-pointer-types"
# then run
bundle install
```

### ✈️ Run App Locally

1. Make sure you have [setup the project](#setup-project).
2. Run the following command.
   ```bash
   $ bundle exec rails server
   ```
3. The project will be served at `localhost` port `3001`. Use Postman to test each [endpoints](#api-documentation).

### Ruby Version Issues
#### Problem: `rbenv: version '3.0.7' is not installed`

**Solution:**
1. **Check available Ruby versions:**
   ```bash
   rbenv versions
   ```

2. **Install Ruby 3.0.7 (if needed):**
   ```bash
   # For macOS users (especially M1/M2)
   RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)" rbenv install 3.0.7

   # Alternative approach if above fails
   brew install openssl@1.1 readline libyaml gmp
   RUBY_CONFIGURE_OPTS="--with-openssl-dir=/opt/homebrew/opt/openssl@1.1 --with-readline-dir=/opt/homebrew/opt/readline --with-libyaml-dir=/opt/homebrew/opt/libyaml --with-gmp-dir=/opt/homebrew/opt/gmp" rbenv install 3.0.7
   ```

3. **Set local Ruby version:**
   ```bash
   rbenv local 3.0.7
   rbenv rehash
   ```

#### Problem: `Your Ruby version is X.X.X, but your Gemfile specified 3.0.7`

**Solution:**
1. Make sure you're in the project directory
2. Set the correct Ruby version:
   ```bash
   rbenv local 3.0.7
   ruby --version  # Should show 3.0.7
   ```
3. If still having issues, try:
   ```bash
   rbenv rehash
   bundle install
   ```

#### Problem: Ruby compilation fails on macOS (especially newer versions)

**Solution:**
```bash
# Update ruby-build and rbenv
brew update
brew upgrade rbenv ruby-build

# Install required dependencies
brew install readline libyaml gmp

# For OpenSSL, check if you have conflicts
brew list | grep openssl
# If you see openssl@1.1 from different taps, uninstall first:
# brew uninstall openssl@1.1 && brew install openssl@1.1

# Install with specific flags for macOS compatibility
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1) --with-readline-dir=$(brew --prefix readline) --with-libyaml-dir=$(brew --prefix libyaml) --with-gmp-dir=$(brew --prefix gmp)"
rbenv install 3.0.7
```

### Bundle/Gem Issues

#### Problem: Permission errors during `bundle install`

**Solution:**
```bash
# Don't use sudo with rbenv
bundle install --path vendor/bundle
```

### Database Issues

#### Problem: PostgreSQL connection errors

**Solution:**
1. **Check if PostgreSQL is running:**
   ```bash
   brew services list | grep postgresql
   ```

2. **Start PostgreSQL if not running:**
   ```bash
   brew services start postgresql@12  # or your version
   ```

3. **Create database user if needed:**
   ```bash
   createuser -s msign_backend
   ```

## 📄 Documentations

### Postman

To test the single sign endpoint, you can use the following `curl` command.

**URL:** `http://localhost:3000/api/v1/single_sign`

**Method:** `POST`

**Headers:**
*   `Content-Type: application/json`

**Body (raw JSON):**
```json
{
    "envelope_id": "64108186-90b5-4350-a5dc-5a349dd72315",
    "signer": "cincaugoreng@yopmail.com",
    "signature": ""
}
```
The `signature` field should contain the base64 encoded signature.

**Curl Command:**
```bash
curl --location 'http://localhost:3000/api/v1/single_sign' \
--header 'Content-Type: application/json' \
--data-raw '{
    "envelope_id": "64108186-90b5-4350-a5dc-5a349dd72315",
    "signer": "cincaugoreng@yopmail.com",
    "signature": ""
}'
```
The `signature` in the data raw is a base64 encoded string.

### Multiple Sign

To test the multiple sign endpoint for certified documents, you can use the following `curl` command.

**URL:** `http://localhost:3000/api/v1/multiple_sign`

**Method:** `POST`

**Headers:**
*   `Content-Type: application/json`

**Body (raw JSON):**
```json
{
  "certified_doc_signature": [
    {
      "id": "D7pQzP7WeX",
      "value": "{{base64_signature}}"
    },
    {
      "id": "J0KvAqygmU",
      "value": "{{base64_signature}}"
    },
    {
      "id": "pEYW7za2mn",
      "value": "{{base64_signature}}"
    },
    {
      "id": "2duO7uXb9Q",
      "value": "{{base64_signature}}"
    },
    {
      "id": "VMoI6ykMXX",
      "value": "{{base64_signature}}"
    },
    {
      "id": "fE3E0eu18r",
      "value": "{{base64_signature}}"
    },
    {
      "id": "5-T-M2wG0d",
      "value": "{{base64_signature}}"
    },
    {
      "id": "S5LgzNACzr",
      "value": "{{base64_signature}}"
    },
    {
      "id": "VKaGEY0sIq",
      "value": "{{base64_signature}}"
    },
    {
      "id": "XbemKmM28M",
      "value": "{{base64_signature}}"
    }
  ]
}
```
The `id` should be a valid annotation ID from the document.

The `value` field should contain the base64 encoded signature image.

The following annotation IDs are created in `db/seeds/envelopes.seeds.rb` for the certified document. These can be used when testing the `multiple_sign` endpoint.


**Curl Command:**
```bash
curl --location --globoff '{{host}}/users/envelopes/559b838d-3ffa-425e-a64d-e4cc3bc7a5a3/signing' \
--header 'Authorization: Bearer 0b4ff853-0cce-4d39-8cfe-49b33f930c9a' \
--header 'Content-Type: application/json' \
--data-raw '{
    "certified_doc_signature": [
        {
            "id": "D7pQzP7WeX",
            "value": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        }
    ]
}'
```
**Note:** The `value` in the `data-raw` is a placeholder for a 1x1 pixel transparent PNG. You should replace it with your actual base64 encoded signature.
