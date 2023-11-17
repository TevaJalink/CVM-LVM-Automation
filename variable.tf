variable "AMI" {
  type    = string
}

variable "instance_type" {
  type    = string
  default = "m5.2xlarge"
}

variable "security_groups_developer" {
  type    = list(any)
  default = ["sg-07105dcf7df6466f8", "sg-0f635e54a71fddcf9", "sg-03145df3e9494ba41", "sg-0595212449a1072bf", "sg-04a5f080056c8b5c2"]
}

variable "security_groups_supportteam" {
  type    = list(any)
  default = ["sg-081c4167de9334f6a", "sg-0b1fd1bc033ee4e07", "sg-0e024372a30faa8f1", "sg-0271707a6d1611b36", "sg-02eea39ef72f403b4", "sg-04665f192fbe88794"]
}

variable "key_name_developer" {
  type    = string
  default = "CVM-LVM"
}

variable "key_name_supportteam" {
  type    = string
  default = "CVM-LVM-SupportTeam"
}

variable "subnet_id_developer" {
  type    = list(any)
  default = ["subnet-09ff541150c0b2116", "subnet-0d50e287ffa2ac044"]
}

variable "subnet_id_supportteam" {
  type    = list(any)
  default = ["subnet-0e37e936bb08dd4f8", "subnet-04510a848cac46dee"]
}

variable "instance_name" {
  type = string
}


variable "LinuxMachine" {
  type = bool
}

variable "WindowsMachine" {
  type = bool
}

variable "working_directory" {
  type = string
}

variable "temp_directory" {
  type = string
}

variable "MachineType" {
  type = bool
}