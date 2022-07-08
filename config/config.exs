import Mix.Config

config :ex_deployer, Axis.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.mailtrap.io",
  port: 2525,
  username: "c1775f9f09078e",
  password: "d97d349ba7fe21",
  # can be `:always` or `:never`
  tls: :if_available,
  # can be `true`
  ssl: false,
  retries: 1

# import_config "#{Mix.env()}.exs"
config :ex_deployer, Axis.DeployResource, """
{
  "repository": {
    "project_id": "",
    "private_token": "",
    "deploy": {
      "user": "",
      "token": ""
    }
  },
  "env": {
    "backup": {
      "active": false,
      "send_to": []
    }
  },
  "project": {
    "name": "",
    "directory": ""
  },
  "hosts": {
    "0.0.0.0": {
      "user": "root",
      "password": "hgwduhjduwedwednwe",
      "tasks": [
        {
          "description": "clone project in dir",
          "command": "git clone --origin deploy --branch {{BRANCH}} {{URL_REPOSITORY}} {{PROJECT_DIR}}",
          "log": false
        },
        {
          "description": "execute composer install",
          "command": "composer install --working-dir={{PROJECT_DIR}}",
          "log": true
        },
        {
          "description": "add remote in origin in project",
          "command": "git --git-dir={{PROJECT_DIR}}/.git remote add origin {{URL_REPOSITORY_ORIGIN}}",
          "log": false
        }
      ]
    }
  }
}
"""
