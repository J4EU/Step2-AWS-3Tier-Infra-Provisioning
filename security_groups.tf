# Web 서버 보안 그룹
resource "aws_security_group" "guestbook_web-sg" {
  name        = "guestbook-web-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.guestbook_vpc.id

  # 인바운드 (HTTP 80 포트 허용)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 인바운드 (SSH 22 포트 허용) 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 (나가는 모든 통신 허용)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "guestbook-web-sg"
  }
}

# WAS 서버 보안 그룹
resource "aws_security_group" "guestbook_was_sg" {
  name        = "guestbook_was-sg"
  description = "Allow traffic from Web SG"
  vpc_id      = aws_vpc.guestbook_vpc.id

  # 인바운드 (Web SG로부터 오는 8000 포트 허용)
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.guestbook_web-sg.id]
  }

  # 인바운드 (Web SG로부터 오는 22 포트 허용)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.guestbook_web-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "guestbook-was-sg"
  }
}

# DB 서버 보안 그룹
resource "aws_security_group" "guestbook_db_sg" {
  name        = "guestbook_db-sg"
  description = "Allow traffic from WAS SG"
  vpc_id      = aws_vpc.guestbook_vpc.id

  # 인바운드 (WAS SG로부터 오는 3306 포트 허용)
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.guestbook_was_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.guestbook_was_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "guestbook-db-sg"
  }
}

resource "aws_security_group" "guestbook_nat_sg" {
  name        = "guestbook-nat-sg"
  description = "Allow inbound traffic from private subnets"
  vpc_id      = aws_vpc.guestbook_vpc.id

  # 프라이빗 서브넷 대역에서 오는 모든 요청을 허용
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.2.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "guestbook-nat-sg"
  }
}
