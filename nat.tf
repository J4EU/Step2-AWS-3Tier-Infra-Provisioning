resource "aws_instance" "guestbook_nat_instance" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  key_name      = "guestbook-web"

  subnet_id              = aws_subnet.guestbook_public_sn.id
  vpc_security_group_ids = [aws_security_group.guestbook_nat_sg.id]

  source_dest_check = false

  user_data = <<-EOF
    #!/bin/bash
    dnf install iptables-services -y

    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

    iptables -F
    iptables -P FORWARD ACCEPT

    IFACE=$(ip route | grep default | awk '{print $5}')
    iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE
    EOF

  tags = {
    Name = "guestbook-nat-instance"
  }
}

resource "aws_eip" "guestbook_nat_eip" {
  instance = aws_instance.guestbook_nat_instance.id

  # EIP를 특정 VPC 안에서 사용하기 위해 할당 받겠다라는 선언
  domain = "vpc"

  tags = {
    Name = "guestbook-nat-eip"
  }
}
