data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# Declaring task for admin
resource "aws_ecs_task_definition" "admin" {
  family                   = "admin"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name         = "admin"
      image        = "public.ecr.aws/j4n7b8s5/songbooksofpraise-admin:16"
      cpu          = 1024
      memory       = 2048
      essential    = true
      network_mode = "awsvpc"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # volume {
  #   name      = "service-storage"
  #   host_path = "/ecs/service-storage"
  # }
}

resource "aws_ecs_cluster" "songbooks_of_praise" {
  name = "songbooks_of_praise"
}

resource "aws_ecs_service" "songbooks_of_praise_admin" {
  name            = "songboos-of-praise-admin"
  cluster         = aws_ecs_cluster.songbooks_of_praise.id
  task_definition = aws_ecs_task_definition.admin.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.songbooks_of_praise_security_group.id]
    subnets          = [aws_subnet.songbooks_of_praise_admin.id]
    assign_public_ip = true
  }

  depends_on = [aws_subnet.songbooks_of_praise_admin]
}

# resource "aws_ecs_task_set" "songbooks_of_praise_admin" {
#   service           = aws_ecs_service.songbooks_of_praise_admin.id
#   cluster           = aws_ecs_cluster.songbooks_of_praise.id
#   task_definition   = aws_ecs_task_definition.admin.arn
#   launch_type       = "FARGATE"
#   wait_until_stable = true

#   network_configuration {
#     security_groups   = [aws_security_group.songbooks_of_praise_security_group.id]
#     subnets           = [aws_subnet.songbooks_of_praise_admin.id]
#     assign_public_ip  = true 
#   }

#   depends_on = [aws_ecs_service.songbooks_of_praise_admin]
# }