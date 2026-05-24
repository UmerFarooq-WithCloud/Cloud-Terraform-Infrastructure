resource "null_resource" "file_provisioner" {
  depends_on = [module.ec2_instance_for_public]
  # connection block for provisioner connect to ec2_instance
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = ""
    host        = aws_eip.elastic_ip.public_ip
    private_key = file("private_key/titan_attack.pem")
  }

  ## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    source      = "private_key/titan_attack.pem"
    destination = "/tmp/titan_attack.pem"
  }

  #remote execusion of file in our public ec2 instance 
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/titan_attack.pem"
    ]
  }
  ## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "local-exec" {
    command     = "echo VPC created on `date` and VPC_id:${module.vpc.vpc_id} >> created_time_vpc_id.txt"
    working_dir = "record_provider_data/"
    on_failure  = continue
  }

  ## Local Exec Provisioner:  local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  #     provisioner "local-exec" {
  #     command = "echo Destroy time prov `date` >> destroy-time-prov.txt"
  #     working_dir = "local-exec-output-files/"
  #     when = destroy
  #     #on_failure = continue
  #   }
}






