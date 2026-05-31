# Generate random value for the login password
resource "random_password" "mysql_username_password" {
  length           = 12
  lower            = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  override_special = "_"
  special          = true
  upper            = true
}