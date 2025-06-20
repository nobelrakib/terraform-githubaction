#resource "tls_private_key" "key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.environment}-key"
  #public_key = tls_private_key.key.public_key_openssh
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaQr/kFVQCU46XCAUneQqwDBurEKIRrrSYm0vW1nvl+n5DH/SOX74jsp6NCPSewn5isTb6+BT141jyiWs31+JafWRdXYgFLqrUN0lZYr7kjkhZ7wY3m5eEVVd4ig1jtko96HdFvZxpNQlrKYOCpx7ppb+kUOWwvGt6W3elk49+cZn+4N8sPTuU3aFOnzdt1dKIlYL65se8rGloZHI60Z4qvELW+GFxAG8KpIUu2Pwkv+xw//IeMFADjZNIomoW0T6DXNvI7lHkrNi5Qb+HtqN91bWK837ZkKRBSsHMy8qS9USUQJc2yLTMiNiyaIvvTBmsbXA1Rm+n3mQEZakE8/fB94Dg9mlIPGbIQZCKgE00NKNNME3A88mnZxkzc9+87/znoI5Mg2MxBDC93S48OwQJz7h144EaSb1hJkZXuHl2f33Gdxnwfhr5sjTLUywzAUP/HA8RCkPcStUxaiTPCKDgS/BOv9urFtXexrFx2J9qxi047hy7B25iGaiXqpRm12sJCrsiT0bH5Wm8sUdL1EmdLryAOdmcQxuztCWOxdYe0cPgOvxfcIVM8YwISXfaaKUF8d8KxnputNw4DZDtIkwAtn7oxXtpTM6LlY9B7gasfwBVK5CK0EK14blmrnH0qx2hoUdyyOm4CKjv1n0saPalbFBnMAsJTEuCosQVzlABJw== your_email@example.com"

}

#resource "local_file" "private_key" {
#  content         = tls_private_key.key.private_key_pem
#  filename        = "${path.module}/${var.environment}-key.pem"
#  file_permission = "0400"
#} 
