variable vpc_cidr_block {
    default = "10.0.0.0/16"
}
variable subnet_cidr_block {
    default = "10.0.10.0/24"
}
variable availability_zone {
    default = "eu-central-1a"
}
variable env_prefix {
    default = "dev"
}
variable my_ip {
    default = "24.133.122.233/32"
}
variable instance_type {
    default = "t4g.small"
}
variable key_name {
    default = "global-key"
}

variable jenkins_ip {
    default = "18.184.142.234/32"
}
