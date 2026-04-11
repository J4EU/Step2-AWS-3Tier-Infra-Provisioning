resource "aws_instance" "guestbook_nat_instance" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  key_name      = "guestbook-web"

  subnet_id              = aws_subnet.guestbook_public_sn.id
  vpc_security_group_ids = [aws_security_group.guestbook_nat_sg.id]

  source_dest_check = false

  user_data = <<-EOF
    #!/bin/bash
    echo "net.ipv4.ip_forwawrd = 1" >> /etc/systctl.conf
    sysctl -p
    
    dnf install -y iptables-services
    systemctl enable --now iptables

    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    service iptables save
    EOF

  tags = {
    Name = "guestbook-nat-instance"
  }
}
