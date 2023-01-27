# Declaring VPC
resource "aws_vpc" "songbooks_of_praise_network" {
  cidr_block = "192.168.0.0/24"
}

resource "aws_internet_gateway" "songbooks_of_praise_gw" {
  vpc_id = aws_vpc.songbooks_of_praise_network.id
}

resource "aws_route_table" "songbooks_of_praise_route_table" {
  vpc_id = aws_vpc.songbooks_of_praise_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.songbooks_of_praise_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.songbooks_of_praise_gw.id
  }
}

resource "aws_security_group" "songbooks_of_praise_security_group" {
  name        = "allow_all"
  description = "Allow ALL inbound traffic"
  vpc_id      = aws_vpc.songbooks_of_praise_network.id

  ingress {
    description = "ALL traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/26", "192.168.0.64/26"]
  }
}

# Setting up subnet for admin containers
resource "aws_subnet" "songbooks_of_praise_admin" {
  vpc_id                  = aws_vpc.songbooks_of_praise_network.id
  map_public_ip_on_launch = true
  cidr_block              = "192.168.0.0/26"
}

resource "aws_network_interface" "songbooks_of_praise_admin" {
  subnet_id       = aws_subnet.songbooks_of_praise_admin.id
  security_groups = [aws_security_group.songbooks_of_praise_security_group.id]
}

resource "aws_route_table_association" "songbooks_of_praise_admin" {
  subnet_id      = aws_subnet.songbooks_of_praise_admin.id
  route_table_id = aws_route_table.songbooks_of_praise_route_table.id
}

# resource "aws_eip" "songbooks_of_praise_admin" {
#   vpc        = true
#   depends_on = [aws_internet_gateway.songbooks_of_praise_gw]
# }

# resource "aws_nat_gateway" "songbooks_of_praise_admin" {
#   allocation_id = aws_eip.songbooks_of_praise_admin.id
#   subnet_id     = aws_subnet.songbooks_of_praise_admin.id

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.songbooks_of_praise_gw]
# }

# Setting up subnet for backend containers
resource "aws_subnet" "songbooks_of_praise_backend" {
  vpc_id     = aws_vpc.songbooks_of_praise_network.id
  cidr_block = "192.168.0.64/26"
}

resource "aws_network_interface" "songbooks_of_praise_backend" {
  subnet_id       = aws_subnet.songbooks_of_praise_backend.id
  security_groups = [aws_security_group.songbooks_of_praise_security_group.id]
}

# Setting up public acl for admin and backend subnets
resource "aws_network_acl" "songbooks_of_praise_public_acl" {
  vpc_id     = aws_vpc.songbooks_of_praise_network.id
  subnet_ids = [aws_subnet.songbooks_of_praise_admin.id, aws_subnet.songbooks_of_praise_backend.id]

  egress {
    protocol   = "all"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}


# Setting up private subnet for databases
resource "aws_subnet" "songbooks_of_praise_databases" {
  vpc_id     = aws_vpc.songbooks_of_praise_network.id
  cidr_block = "192.168.0.128/26"
}

resource "aws_network_interface" "songbooks_of_praise_databases" {
  subnet_id       = aws_subnet.songbooks_of_praise_databases.id
  security_groups = [aws_security_group.songbooks_of_praise_security_group.id]
}

# Setting up private acl for databases subnet
resource "aws_network_acl" "songbooks_of_praise_private_acl" {
  vpc_id     = aws_vpc.songbooks_of_praise_network.id
  subnet_ids = [aws_subnet.songbooks_of_praise_databases.id]

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "192.168.0.64/26"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "192.168.0.64/26"
    from_port  = 0
    to_port    = 0
  }
}