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
      "type" => "object",
      "properties" => %{
        "repository" => %{
          "type" => "object",
          "properties" => %{
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
          "required" => ["project_id", "private_token"]
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
                  "minItems" => 1,
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
          "minProperties" => 1
        },
        "driver" => %{
          "type" => "string",
          "minLength" => 1
        },
        "strategy" => %{
          "type" => "string",
          "minLength" => 1
        }
      },
      "additionalProperties" => false
    }
  end
end
