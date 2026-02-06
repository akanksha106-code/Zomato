resource "aws_instance" "test-server" {
  ami                         = "ami-0532be01f26a3de55"
  instance_type               = "t3.small"
  key_name                    = "zomato-keypair"
  vpc_security_group_ids      = ["sg-01da398717a940515"]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./zomato-keypair.pem")
    host        = self.public_ip
  }

  # Wait for EC2 to be ready
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for EC2 instance to be ready...'"
    ]
  }

  tags = {
    Name = "test-server"
  }

  # Create inventory file for Ansible
  provisioner "local-exec" {
    command = "echo '${self.public_ip}' > ./inventory"
  }

  # Run Ansible playbook
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=./ansible.cfg ansible-playbook ./ansiblebook.yml"
  }
}
