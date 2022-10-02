defmodule Axis.Validator do
  def validate(_config, []) do
    :ok
  end

  def validate(config, :config) do
    schema()
    |> ExJsonSchema.Schema.resolve()
    |> ExJsonSchema.Validator.validate(config)
  end

  defp schema do
    %{
      "$schema" => "http://json-schema.org/draft-06/schema#",
      "$id" => "http://json-schema.org/draft-06/schema#",
      "type" => "object",
      "properties" => %{
        "repository" => %{
          "type" => "object",
          "properties" => %{
            "driver" => %{
              "type" => "string",
              "minLength" => 1,
              "enum" => [
                "gitlab",
                "github"
              ]
            },
            "project_id" => %{
              "type" => "integer"
            },
            "deploy" => %{
              "type" => "object",
              "properties" => %{
                "user" => %{
                  "type" => "string",
                  "minLength" => 1
                },
                "token" => %{
                  "type" => "string",
                  "minLength" => 1
                }
              },
              "required" => ["user", "token"]
            },
            "private_token" => %{
              "type" => "string",
              "minLength" => 1
            }
          },
          "required" => ["project_id", "private_token", "driver", "deploy"]
        },
        "env" => %{
          "type" => "object",
          "properties" => %{
            "backup" => %{
              "type" => "object",
              "properties" => %{
                "active" => %{
                  "type" => "boolean"
                },
                "send_to" => %{
                  "type" => "array",
                  "minItems" => 0,
                  "uniqueItems" => true
                }
              }
            }
          }
        },
        "project" => %{
          "type" => "object",
          "properties" => %{
            "name" => %{
              "type" => "string",
              "minLength" => 1
            },
            "directory" => %{
              "type" => "string",
              "minLength" => 1
            }
          }
        },
        "hosts" => %{
          "type" => "object",
          "minProperties" => 1,
          "propertyNames" => %{
            "pattern" => "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$"
          },
          "patternProperties" => %{
            "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$" => %{
              "type" => "object",
              "properties" => %{
                "user" => %{
                  "type" => "string",
                  "minLength" => 1
                },
                "password" => %{
                  "type" => "string",
                  "minLength" => 1
                },
                "directory" => %{
                  "type" => "string",
                  "minLength" => 1
                },
                "tasks" => %{
                  "type" => "array",
                  "minItems" => 0,
                  "items" => %{
                    "type" => "object",
                    "properties" => %{
                      "command" => %{
                        "type" => "string",
                        "minLength" => 3
                      },
                      "description" => %{
                        "type" => "string",
                        "minLength" => 3
                      },
                      "log" => %{
                        "type" => "boolean"
                      },
                      "if" => %{
                        "type" => "object",
                        "properties" => %{
                          "project_exist" => %{
                            "type" => "boolean"
                          }
                        }
                      }
                    },
                    "required" => [
                      "command",
                      "log",
                      "description"
                    ]
                  }
                }
              }
            }
          }
        },
        "strategy" => %{
          "type" => "string",
          "minLength" => 1,
          "enum" => [
            "clone-always",
            "checkout-tag"
          ]
        },
        "debug" => %{
          "type" => "boolean"
        }
      },
      "required" => [
        "strategy",
        "repository",
        "hosts",
        "project",
        "env"
      ],
      "additionalProperties" => true
    }
  end
end
