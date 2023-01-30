# resource "mongodbatlas_project" "songbooks_of_praise" {
#   name   = "songbooks-of-praise"
#   org_id = "6269a80360265a29cce5a1c9"
# }

# resource "mongodbatlas_project_ip_access_list" "test" {
#   project_id = mongodbatlas_project.songbooks_of_praise.id
#   cidr_block = "0.0.0.0/0"
# }

# resource "mongodbatlas_database_user" "test" {
#   username           = "test-acc-username"
#   password           = "test-acc-password"
#   project_id         = "<PROJECT-ID>"
#   auth_database_name = "admin"

#   roles {
#     role_name     = "readWrite"
#     database_name = "dbforApp"
#   }

#   roles {
#     role_name     = "readAnyDatabase"
#     database_name = "admin"
#   }

#   labels {
#     key   = "My Key"
#     value = "My Value"
#   }

#   scopes {
#     name   = "My cluster name"
#     type = "CLUSTER"
#   }

#   scopes {
#     name   = "My second cluster name"
#     type = "CLUSTER"
#   }
# }