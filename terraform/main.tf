resource "yandex_vpc_network" "network" {                                                   
  name = "network"
}

resource "yandex_vpc_subnet" "public_a" {                                                   
  name = "public_a"
  v4_cidr_blocks = ["10.0.0.0/24"]
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
}

resource "yandex_vpc_subnet" "private_a" {                                                 
  name = "private_a"
  v4_cidr_blocks = ["10.0.1.0/24"]
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
  route_table_id = yandex_vpc_route_table.route.id
}

resource "yandex_vpc_address" "bastion_ip" {                                                
    external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_route_table" "route" {                                                 
  name = "route"
  network_id = yandex_vpc_network.network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.gateway.id
  }
}

resource "yandex_vpc_gateway" "gateway" {                                                   
  name = "gateway"
  shared_egress_gateway {}
}

resource "yandex_dns_zone" "public_zone" {                                                  
  name = "public"
  zone = "${var.domain}."
  public = true
}

resource "yandex_dns_zone" "private_zone" {                                                 
  name = "private"
  zone = "private."
  private_networks = [yandex_vpc_network.network.id]
}

resource "yandex_cm_certificate" "cert" {                                                     
  name = "cert"
  domains = [ var.domain ]
  managed {
    challenge_type = "DNS_CNAME"
  }
}

resource "yandex_dns_recordset" "rs_cert" {                                                   
  zone_id = yandex_dns_zone.public_zone.id
  name = yandex_cm_certificate.cert.challenges.0.dns_name
  type = yandex_cm_certificate.cert.challenges.0.dns_type
  ttl = 200
  data = [yandex_cm_certificate.cert.challenges.0.dns_value]
}

resource "yandex_dns_recordset" "rs_bastion" {                                             
  name = "bastion"
  zone_id = yandex_dns_zone.public_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.bastion.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs_bastion_gitlab" {                                      
  name = "gitlab"
  zone_id = yandex_dns_zone.public_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.bastion.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs_gitlab" {                                               
  name = "gitlab"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.gitlab.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs_m_node_a_0" {                                               
  name = "m-node-a-0"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.m_node_a_0.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs_w_node_0" {                                             
  name = "w-node-0"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.w_node_0.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs_w_node_1" {                                             
  name = "w-node-1"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.w_node_1.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs_haproxy" {                                             
  name = "haproxy"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.haproxy.network_interface.0.ip_address]
}

resource "yandex_vpc_security_group" "bastion_security"{                                  
  name = "bastion_security"                                                               
  network_id = yandex_vpc_network.network.id                                              
  ingress {
    description = "SSH"
    protocol = "TCP"
    port = 22
    v4_cidr_blocks = ["10.0.0.10/32", "10.0.1.0/24"]
  }
  ingress {
    description = "DNS TCP"
    protocol = "TCP"
    port = 53
    v4_cidr_blocks = ["10.0.0.10/32", "10.0.1.0/24"]
  }
  ingress {
    description = "DNS UDP"
    protocol = "UDP"
    port = 53
    v4_cidr_blocks = ["10.0.0.10/32", "10.0.1.0/24"]
  }
  ingress {
    description = "HTTP"
    protocol = "TCP"
    port = 80
    v4_cidr_blocks = ["10.0.0.10/32", "10.0.1.0/24"]
  }
  ingress {
    description = "HTTPS"
    protocol = "TCP"
    port = 443
    v4_cidr_blocks = ["10.0.0.10/32", "10.0.1.0/24"]
  }
  egress {
    description = "ANY"
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "bastion" {                                            
  # checkov:skip=CKV_YC_2: Bastion host требует публичного IP
  name = "bastion"                                                                       
  zone = "ru-central1-a"                                                                  
  hostname = "bastion"                                                                  
  resources {                                                                                                                         
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public_a.id
    nat = true
    nat_ip_address = yandex_vpc_address.bastion_ip.external_ipv4_address.0.address
    security_group_ids = [yandex_vpc_security_group.bastion_security.id]
    ip_address = "10.0.0.10"
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.bastion_security.id]
    ip_address = "10.0.1.10"
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}

resource "yandex_compute_instance" "vault" {                                            
  name = "vault"                                                                        
  zone = "ru-central1-a"                                                                
  hostname = "vault"                                                                  
  resources {                                                                                                                         
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.bastion_security.id]
    ip_address = "10.0.1.11"
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}

resource "yandex_compute_instance" "gitlab" {                                               
  name = "gitlab"                                                                           
  zone = "ru-central1-a"                                                                    
  hostname = "gitlab"                                                                     
  resources {                                                                                                                        
    cores = 4                                                                   
    memory = 8                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
      size = 16
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.bastion_security.id]
    ip_address = "10.0.1.12"
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}

resource "yandex_compute_instance" "haproxy" {                                            
  name = "haproxy"                                                                        
  zone = "ru-central1-a"                                                               
  hostname = "haproxy"                                                                  
  resources {                                                                                                                         
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.bastion_security.id]
    ip_address = "10.0.1.13"
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}
///

resource "yandex_compute_instance" "m_node_a_0" {                                             
  name = "m-node-a-0"                                                                        
  zone = "ru-central1-a"                                                                  
  hostname = "m-node-a-0"                                                                  
  resources {                                                                                                                        
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.bastion_security.id]
    ip_address = "10.0.1.20"
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}

resource "yandex_compute_instance" "w_node_0" {                                            
  name = "w-node-0"                                                                         
  zone = "ru-central1-a"                                                                    
  hostname = "w-node-0"                                                                    
  resources {                                                                                                                        
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.bastion_security.id]
    ip_address = "10.0.1.30"
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}

resource "yandex_compute_instance" "w_node_1" {                                            
  name = "w-node-1"                                                                         
  zone = "ru-central1-a"                                                                    
  hostname = "w-node-1"                                                                    
  resources {                                                                                                                        
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    security_group_ids = [yandex_vpc_security_group.bastion_security.id]
    ip_address = "10.0.1.31"
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}
