# 최신 Amazon Linux 2023 AMI 정보 가져오기
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# Web 서버 EC2 인스턴스 생성
resource "aws_instance" "guestbook_web_server" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"

  # 키 페어 설정
  key_name = "guestbook-web"

  # 퍼블릭 서브넷에 배치
  subnet_id = aws_subnet.guestbook_public_sn.id

  # Web 보안 그룹 연결
  vpc_security_group_ids = [aws_security_group.guestbook_web-sg.id]

  # 퍼블릭 IP 자동 할당
  associate_public_ip_address = true

  # Nginx 설치 스크립트
  user_data = <<-EOF
        #!/bin/bash
        dnf update -y
        dnf install -y nginx
        systemctl enable --now nginx

        # 로컬의 index.html 내용을 서버의 index.html로 저장
        cat << 'HTML' > /usr/share/nginx/html/index.html
        ${file("./index.html")}
        HTML

        chown nginx:nginx /usr/share/nginx/html/index.html
        EOF

  tags = {
    Name = "guestbook-web-server"
  }
}

# Web 서버 인스턴스에 EIP 할당
resource "aws_eip" "guestbook_web_eip" {
  instance = aws_instance.guestbook_web_server.id

  # EIP를 특정 VPC 안에서 사용하기 위해 할당 받겠다라는 선언
  domain = "vpc"

  tags = {
    Name = "guestbook-web-eip"
  }
}
