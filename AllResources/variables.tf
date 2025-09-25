variable vm_name{
    type = string
    description = "This variable used to provide VM name"
}

variable vm_user_name{
    type = string
    description = "This variable used to provide VM user name"
}

variable vm_user_password{
    type = string
    description = "This variable used to provide VM password"
    sensitive = true
}

variable vm_size{
    type = string
    description = "This variable is used to pass VM size value but has defualt in it"
    default = "Standard_B2s"
}