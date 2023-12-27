# Galliora

Simple web gallery with images split by categories. \
Powered by Ruby on Rails 7 with all its new cool stuff (such as Turbo) and Bootstrap 5.

## Getting Started


### Requirements:

In order to set up and run the project on your local machine, you need this
software installed:

1. Ruby 3.2.2
2. Node.js 20.10.0
3. PostgreSQL 16
4. ImageMagick

--------

### Installation:

#### Step 1

Clone the project from the repository:

```shell
cd <your_projects_root_folder>
git clone <link_to_galliora_repo>
cd galliora
```

#### Step 2

Install tools for Ruby and Node version management from one of the variants:
- [asdf](https://asdf-vm.com/guide/getting-started.html) tool version manager with [Ruby](https://github.com/asdf-vm/asdf-ruby) and [Node](https://github.com/asdf-vm/asdf-nodejs) plugins
- Separate Ruby and Node version management tools:
  1. Ruby: [RVM](https://rvm.io/rvm/install) or [rbenv](https://github.com/rbenv/rbenv#installation)
  2. Node: [NVM](https://github.com/nvm-sh/nvm#installing-and-updating)

**asdf** is recommended since its ability to work with Ruby and Node at once. Because of that, the following instructions will be for this version manager.

#### Step 3

Install Ruby 3.2.2 version:

```shell
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 3.2.2
```

#### Step 4

Install Node 20.10.0 (LTS) version:

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs 20.10.0
```

#### Step 5

After installing Ruby and Node, you can either configure your asdf to use `.ruby-version` and `.node-version` to set local Ruby and Node versions (1) or set them in the default asdf way - by creating a `.tool-versions` file (2).

1. To use `.ruby-version` and `.node-version` files, you need to add the following line to your asdf configuration file `$HOME/.asdfrc`:

    ```
    legacy_version_file = yes
    ```

2. To set Ruby and Node versions with the default for asdf `.tool-versions` file, you need to execute these asdf commands:

    ```shell
    asdf local ruby 3.2.2
    asdf local nodejs 20.10.0
    ```

#### Step 6

Install PostgreSQL database (instructions are written for Debian / Ubuntu):

1. Add the PostgreSQL 16 repository:

```shell
sudo apt update
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```

2. Import the repository signing key:

```shell
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
sudo apt update
```

3. Install PostgreSQL 16 and contrib modules:

```shell
sudo apt install postgresql-16 postgresql-contrib-16
```

4. Start and enable PostgreSQL service:

```shell
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

In order to create your postgres user, run this command:

```shell
sudo -u postgres psql
```

```sql
CREATE ROLE <your_user> SUPERUSER LOGIN PASSWORD '<your_password>';
```

In order to prevent possible problems with rails database-related commands, when applying changes to the database, you can do this, **but it is not essential**:
>
> 1. Open the postgres config file with your text editor (nano, vim etc...)
>
> If you're on Debian / Ubuntu:
> ```shell
> sudo <text_editor> /etc/postgresql/16/main/pg_hba.conf
> ```
>
> If you're on Fedora:
> ```shell
> sudo <text_editor> /var/lib/pgsql/data/pg_hba.conf
> ```
>
> 2. Find the line with content like: `local all postgres peer`
>
> 3. Comment it out and paste this line below: `local all all md5`
>
> 4. Restart your Postgres server:
>
> ```shell
> sudo systemctl restart postgresql.service
> ```

#### Step 7

Since ImageMagick image manipulator is used in Carrierwave, check if you already have it installed in your system:

```shell
convert -version
```

If you receive `command not found: convert`, install ImageMagick (instructions are written for Debian / Ubuntu):

```shell
sudo apt update
sudo apt install imagemagick
```

#### Step 8

Install [bundler](https://bundler.io/):

```shell
gem install bundler
```

Run bundler to install the project's dependencies:

```shell
bundle
```

#### Step 9

Create `.env` file in the app's root and add there such environment variables with your values:

```bash
export DB_USERNAME=<value>
export DB_PASSWORD=<value>
export DB_PRODUCTION_USERNAME=<value>
export DB_PRODUCTION_PASSWORD=<value>
```

#### Step 10

Create, migrate and seed the database:

```shell
bin/rake db:create
bin/rake db:migrate
bin/rake db:seed
```

**Congratulations, you have set up the project!**

## Usage

#### Server

```shell
bin/rails s # start up
[ctrl + c] # shut down
```

When up, the project is available on
[http:://localhost:3000](http:://localhost:3000).

#### Console

```shell
bin/rails c # start up
> exit # shut down
```

#### Tests

```shell
bundle exec rspec
```

#### Code style

```shell
bundle exec rubocop
```

--------

Things that maybe should be covered too:

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
