output "workspace" { value = "${terraform.workspace}" }

output "vpc_id" { value = "${aws_vpc.vpc.id}" }

output "subnet_a_public_id" { value = "${aws_subnet.subnet_a_public.id}" }
output "subnet_b_public_id" { value = "${aws_subnet.subnet_b_public.id}" }
output "subnet_a_private_id" { value = "${aws_subnet.subnet_a_private.id}" }
output "subnet_b_private_id" { value = "${aws_subnet.subnet_b_private.id}" }
