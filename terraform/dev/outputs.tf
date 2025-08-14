output "private_sub_id" {
  description = "ID of private subnet"
  value = try(yandex_vpc_subnet.private_a.id, null)
}

output "public_dns_id" {
  description = "ID of public dns zone"
  value = try(yandex_dns_zone.public_zone.id, null)
}

output "private_dns_id" {
  description = "ID of private dns zone"
  value = try(yandex_dns_zone.private_zone.id, null)
}

output "sg_id" {
  description = "ID of bastion security group"
  value = try(yandex_vpc_security_group.bastion_security.id, null)
}

output "external_bastion_ip" {
  description = "external bastion host ip"
  value = try(yandex_compute_instance.bastion.network_interface.0.nat_ip_address, null)
}