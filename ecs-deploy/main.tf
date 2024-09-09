# 1. Providers Configuration (Make sure to have your AWS credentials configured)
provider "aws" {
  region = "eu-west-2"  # Change to your preferred region
}

# 2. Define ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"
}

# 3. Define Security Group to allow inbound traffic (for example, HTTP)
resource "aws_security_group" "ecs_sg" {
  name   = "ecs_security_group"
  vpc_id = "vpc-01a0cb45befe50f0b"  # Replace with your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Define ECS Task Definition
resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 256 CPU units (~0.25 vCPU)
  memory                   = "512"  # 512 MiB of memory

  container_definitions = jsonencode([{
    name      = "nextjspoc"
    image     = "983883494204.dkr.ecr.eu-west-2.amazonaws.com/nextjspoc1d09dd0a82/nextjsfunction032c9ef3repo:nextjsfunction-e331b061856f-v1"  # Example: NGINX image
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }]
  }])
}

# 5. ECS Service
resource "aws_ecs_service" "nextpoc_svc" {
  name            = "nextpoc_svc"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets         = ["subnet-xxxxxx", "subnet-yyyyyy"]  # Replace with your subnet IDs
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
