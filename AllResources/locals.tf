locals {
  rg_name = "app-grp"
  location ="West Europe"
  sg_name = "app-network-sg"
  network_name = "app-network"
  address_spaces = ["10.0.0.0/16", "10.0.0.4", "10.0.0.5"]

  subnets=[
    {
      name = "websubnet01"
      address_prefixes = ["10.0.1.0/24"]
    },
     {
      name = "appsubnet02"
      address_prefixes = ["10.0.2.0/24"]
    }
  ]

  network_interface_name = "appnetworkinterface"
}
