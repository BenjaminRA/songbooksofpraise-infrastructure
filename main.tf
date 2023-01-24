variable "REDIS_VOLUME_PATH" {
  description = "Path where to mount redis volume on the host machine"
  type = string
}
variable "REDIS_PASSWORD" {
  description = "Redis password to secure the connection and transactions"
  type = string
}
variable "MONGO_VOLUME_PATH" {
  description = "Path where to mount mongo volume on the host machine"
  type = string
}
variable "MONGO_INITDB_ROOT_USERNAME" {
  description = "MongoDB username"
  type = string
}
variable "MONGO_INITDB_ROOT_PASSWORD" {
  description = "MongoDB password"
  type = string
}
variable "ADMIN_BUILD_PATH" {
  description = "Path of the admin dockerfile"
  type = string
}
variable "BACKEND_BUILD_PATH" {
  description = "Path of the backend dockerfile"
  type = string
}

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_network" "songbooks_of_praise_network" {
  name = "songbooks_of_praise_network"
}

#######################################################

resource "docker_image" "redis" {
  name = "redis:latest"
}


resource "docker_container" "redis" {
  name = "redis"
  restart = "always"
  image = docker_image.redis.name
  networks_advanced {
    name = docker_network.songbooks_of_praise_network.name
  }
  ports {
    internal = 6379
    external = 6379
  }
  volumes {
    host_path = var.REDIS_VOLUME_PATH
    container_path = "/data"
  }
  command = ["redis-server", "--requirepass", var.REDIS_PASSWORD]
}

#######################################################

resource "docker_image" "mongodb" {
  name = "mongo:latest"
}

resource "docker_container" "mongodb" {
  name = "mongodb"
  restart = "always"
  image = docker_image.mongodb.name
  networks_advanced {
    name = docker_network.songbooks_of_praise_network.name
  }
  ports {
    internal = 27017
    external = 27017
  }
  env = [
    "MONGO_INITDB_ROOT_USERNAME=${var.MONGO_INITDB_ROOT_USERNAME}",
    "MONGO_INITDB_ROOT_PASSWORD=${var.MONGO_INITDB_ROOT_PASSWORD}"
  ]
  volumes {
    host_path = var.MONGO_VOLUME_PATH
    container_path = "/data/db"
  }
}

#######################################################

resource "docker_image" "admin" {
  name = "admin:latest"
  build {
    context = var.ADMIN_BUILD_PATH
  }
}

resource "docker_container" "admin" {
  name = "admin"
  image = docker_image.admin.name
  networks_advanced {
    name = docker_network.songbooks_of_praise_network.name
  }
  ports {
    internal = 80
    external = 3000
  }
}
#######################################################

resource "docker_image" "backend" {
  name = "backend:latest"
  build {
    context = var.BACKEND_BUILD_PATH
  }
}

resource "docker_container" "backend" {
  name = "backend"
  image = docker_image.backend.name
  networks_advanced {
    name = docker_network.songbooks_of_praise_network.name
  }
  ports {
    internal = 8080
    external = 8080
  }
}
