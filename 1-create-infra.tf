# ---------- Create Projects ----------
resource "zedcloud_project" "demo_project_zededa_1" {
  name            = "TF-ZEDEDA-DEMO"
  title           = "TF-ZEDEDA-DEMO"
  type            = "TAG_TYPE_PROJECT"
  tag_level_settings    {
    interface_ordering = "INTERFACE_ORDERING_ENABLED"
    flow_log_transmission   = "NETWORK_INSTANCE_FLOW_LOG_TRANSMISSION_ENABLED"
  }
  edgeview_policy {
      type          = "POLICY_TYPE_EDGEVIEW"
    edgeview_policy {
      access_allow_change = true
      edgeview_allow = true
      edgeviewcfg {
        app_policy {
          allow_app = true
        }
        dev_policy {
          allow_dev = true
        }
        jwt_info {
          disp_url = "zedcloud.gmwtus.zededa.net/api/v1/edge-view"
          allow_sec = 18000
          num_inst = 1
          encrypt = true
        }
        ext_policy {
          allow_ext = true
        }
      }
      max_expire_sec = 2592000
      max_inst = 3
    }
  }
}

# ---------- Create SJC Local Datastore ----------
resource "zedcloud_datastore" "demo_sjc_ds" {
  ds_fqdn = "http://172.16.8.129"
  ds_type = "DATASTORE_TYPE_HTTP"
  name    = "TF-SJC-DS"
  title   = "TF-SJC-DS"
  ds_path = "iso"
  project_access_list = []
}

#######Create a Azure Blob datastore
resource "zedcloud_datastore" "az_blob_ds" {
  name    = "TF-DEMO-AZURE-DS"
  title   = "TF-DEMO-AZURE-DS"
  api_key = var.azure_blob_api_username
  ds_fqdn = var.azure_blob_url
  secret {
    api_passwd = var.azure_blob_password
  }
  ds_type = var.datastore_type
  ds_path = var.azure_ds_path
}

# ---------- Create SJC Ubuntu Image ----------
resource "zedcloud_image" "ubuntu_noble_image" {
  datastore_id = zedcloud_datastore.demo_sjc_ds.id
  image_type = "IMAGE_TYPE_APPLICATION"
  image_arch = "AMD64"
  image_format = "QCOW2"
  image_sha256 = "f1652d29d497fb7c623433705c9fca6525d1311b11294a0f495eed55c7639d1f"
  image_size_bytes = 614746112
  name = "Ubuntu_Cloud_Images_Noble"
  title = "Ubuntu_Cloud_Images_Noble"
  project_access_list = []
  image_rel_url = "noble-server-cloudimg-amd64.img"
}

# ---------- Create FW FIREWALL Image ----------
resource "zedcloud_image" "tf_demo_fw_image" {
  datastore_id = zedcloud_datastore.demo_sjc_ds.id
  image_type = "IMAGE_TYPE_APPLICATION"
  image_arch = "AMD64"
  image_format = "QCOW2"
  image_sha256 = "0e275df6f35b3139d4988afcf4ddd0e3cc9fcf88320877efe0dfd17febe75147"
  image_size_bytes = 100728832
  name = "fortios-7.4.3.qcow2"
  title = "fortios-7.4.3.qcow2"
  project_access_list = []
  image_rel_url = "fortios-7.4.3.qcow2"
}

# ---------- Creating EVE Network Port Config per Project ----------
resource "zedcloud_network" "demo_edge_node_net" {
  name        = "DEMO-EVE-NET"
  title       = "DEMO-EVE-NET"
  description = "Network (DHCP)"
  enterprise_default = false
  kind        = "NETWORK_KIND_V4"
  ip {
    dhcp = "NETWORK_DHCP_TYPE_CLIENT"
  }
  project_id = zedcloud_project.demo_project_zededa_1.id
}

# ---------- Create Brand and Model----------
resource "zedcloud_brand" "demo_brand_proxmox" {
  name        = "TF-pxmx"
  title       = "TF-pxmx"
  origin_type = "ORIGIN_LOCAL"
  logo        = {
    url       = "https://www.proxmox.com/images/proxmox/logos/mediakit-proxmox-server-solutions-logos-light.svg"
  }
}

resource "zedcloud_model" "demo_pxmx_model" {
  name          = "ProxMox-VM-12vcpu-16gMem-2vnic"
  title         = "ProxMox-VM-12vcpu-16gMem-2vnic"
  brand_id      = zedcloud_brand.demo_brand_proxmox.id
  origin_type   = "ORIGIN_LOCAL"
  state         =  "SYS_MODEL_STATE_ACTIVE"
  type          = "AMD64"
  attr          =  {
    memory      = "16G"
    storage     = "150G"
    Cpus        = "8"
  }
 io_member_list {
      ztype         = "IO_TYPE_HDMI"
      usage         = "ADAPTER_USAGE_APP_SHARED"
      phylabel      = "VGA"
      logicallabel  = "VGA"
      cost          = 0
      assigngrp     = ""
      phyaddrs      = { 
        Ifname = "VGA"
        PciLong = "0000:00:02.0" }
    }
  io_member_list {
      ztype        = "IO_TYPE_USB_CONTROLLER"
      usage        = "ADAPTER_USAGE_APP_SHARED"
      phylabel     = "USB"
      assigngrp    = "group"
      phyaddrs     = { 
        Ifname     = "USB"
        PciLong    = "0000:00:01.2" }
      logicallabel = "USB"
      cost         = 0
    }
  io_member_list {
      ztype        = "IO_TYPE_COM"
      phylabel     = "COM1"
      assigngrp    = "COM1"
      phyaddrs     = { 
        Ioports = "3f8-3ff"
        Irq = 16
        Serial = "/dev/ttyS0" }
      logicallabel = "COM1"
      cost         = 0
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth0"
      logicallabel  = "eth0"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth0"
      phyaddrs      = { 
        Ifname = "eth0"
        PciLong = "" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth1"
      logicallabel  = "eth1"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth1"
      phyaddrs      = { 
        Ifname = "eth1"
        PciLong = "" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth2"
      logicallabel  = "eth2"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth2"
      phyaddrs      = { 
        Ifname = "eth2"
        PciLong = "" }
    }
}

# ---------- Create Edge Nodes ---------------------------
resource "zedcloud_edgenode" "demo_edge_node_1" {
  name           = "ZEDEDA-EDGE-NODE-1"
  title          = "ZEDEDA-EDGE-NODE-1"
  project_id     = zedcloud_project.demo_project_zededa_1.id
  model_id       = zedcloud_model.demo_pxmx_model.id
  onboarding_key = var.onboarding_key
  serialno       = var.device_serial
  description    = "Demo"
  admin_state    = "ADMIN_STATE_ACTIVE"
  config_item {
    key          = "debug.enable.ssh"
    string_value = var.ssh_pub_key
    bool_value   = false
    float_value  = 0
    uint32_value = 0
    uint64_value = 0
  }
  config_item {
    bool_value    = false
    float_value   = 0
    key           = "debug.disable.dhcp.all-ones.netmask"
    string_value  = true
    uint32_value  = 0
    uint64_value  = 0
    }
  config_item {
    key          = "debug.enable.console"
    string_value = false
    bool_value   = true
    float_value  = 0
    uint32_value = 0
    uint64_value = 0
    }
  config_item {
    bool_value    = true
    float_value   = 0
    key           = "debug.enable.vga"
    string_value  = true
    uint32_value  = 0
    uint64_value  = 0
    }
  config_item {
    bool_value    = true
    float_value   = 0
    key           = "debug.enable.usb"
    string_value  = true
    uint32_value  = 0
    uint64_value  = 0
    }
  config_item {
    bool_value    = true
    float_value   = 0
    key           = "debug.enable.vnc"
    string_value  = false
    uint32_value  = 0
    uint64_value  = 0
    }
  config_item {
    key          = "process.cloud-init.multipart"
    string_value = true
    bool_value   = true
    float_value  = 0
    uint32_value = 0
    uint64_value = 0
    }
  edgeviewconfig {
    generation_id = 0
    token         = var.edgeview_token
    app_policy {
      allow_app = true
    }
    dev_policy {
      allow_dev = true
    }
    ext_policy {
      allow_ext = true
    }
    jwt_info {
      allow_sec  = 18000
      disp_url   = "zedcloud.gmwtus.zededa.net/api/v1/edge-view"
      encrypt    = true
      expire_sec = "0"
      num_inst   = 3
    }
  }
    interfaces {
        cost       = 0
        intf_usage = "ADAPTER_USAGE_MANAGEMENT"
        intfname   = "COM1"
        tags       = {}
    }
    interfaces {
        cost       = 0
        intf_usage = "ADAPTER_USAGE_MANAGEMENT"
        intfname   = "eth0"
        netname    = zedcloud_network.demo_edge_node_net.name
        tags       = {}
    }
    interfaces {
        cost       = 0
        intf_usage = "ADAPTER_USAGE_APP_SHARED"
        intfname   = "eth1"
        netname    = ""
        tags       = {}
    }
    interfaces {
        cost       = 0
        intf_usage = "ADAPTER_USAGE_APP_SHARED"
        intfname   = "eth2"
        netname    = ""
        tags       = {}
    }
    interfaces {
        cost       = 0
        intf_usage = "ADAPTER_USAGE_APP_SHARED"
        intfname   = "USB"
        netname    = ""
        tags       = {}
    }
    interfaces {
        cost       = 0
        intf_usage = "ADAPTER_USAGE_APP_DIRECT"
        intfname   = "VGA"
        tags       = {}
    }
}

#------------ Edge node has to be created before this step ---------#
#------------ Create Network Instances ----------
resource "zedcloud_network_instance" "demo_mgt_net" {
  name = "mgt-net"
  title = "mgt-net"
  kind = "NETWORK_INSTANCE_KIND_LOCAL"
  type = "NETWORK_INSTANCE_DHCP_TYPE_V4"
  port = "eth0"
  device_id = zedcloud_edgenode.demo_edge_node_1.id
  ip {
    dhcp_range {
    end = "10.0.0.20"
    start = "10.0.0.10"
  }
    dns = [
      "1.1.1.1"
  ]
    domain = ""
    gateway = "10.0.0.1"
    ntp = "64.246.132.14"
    subnet = "10.0.0.0/16"
  }
}

resource "zedcloud_network_instance" "demo_wan_net" {
  name = "wan-net"
  title = "wan-net"
  kind = "NETWORK_INSTANCE_KIND_SWITCH"
  type = "NETWORK_INSTANCE_DHCP_TYPE_UNSPECIFIED"
  port = "eth1"
  device_id = zedcloud_edgenode.demo_edge_node_1.id
 depends_on = []
}

resource "zedcloud_network_instance" "demo_lan_1_net" {
  name = "lan-1-net"
  title = "lan-1-net"
  kind = "NETWORK_INSTANCE_KIND_SWITCH"
  type = "NETWORK_INSTANCE_DHCP_TYPE_UNSPECIFIED"
  port = ""
  device_id = zedcloud_edgenode.demo_edge_node_1.id
}

resource "zedcloud_network_instance" "demo_lan_2_net" {
  name = "lan-2-net"
  title = "lan-2-net"
  kind = "NETWORK_INSTANCE_KIND_SWITCH"
  type = "NETWORK_INSTANCE_DHCP_TYPE_UNSPECIFIED"
  port = ""
  device_id = zedcloud_edgenode.demo_edge_node_1.id
}

# =================== Applications ===========================
# ---------- Create Applications ----------
resource "zedcloud_application" "demo_forgigate_app" {
  name = "fortigate-7.4.3"
  title = "Fortigate-7.4.3"
  networks = 4
  manifest {
    ac_kind = "VMManifest"
    ac_version = "1.2.0"
    name = "Fortigate-7.4.3"
  owner {
    user = "Manny Calero"
    company = "Zededa"
    website = "www.zededa.com"
    email = "manny@zededa.com"
  }
  desc {
    app_category = "APP_CATEGORY_OPERATING_SYSTEM"
    category     = "APP_CATEGORY_OPERATING_SYSTEM"
     logo        = {
       url       = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Fortinet_logo.svg/250px-Fortinet_logo.svg.png" 
      }
    } 
  images {
    imagename = zedcloud_image.tf_demo_fw_image.name
    imageid = zedcloud_image.tf_demo_fw_image.id
    imageformat = "QCOW2"
    cleartext = false
    drvtype = "HDD"
    ignorepurge = true
    maxsize = 40971520
    target = "Disk"
 
    }
  interfaces {
    name = "eth0" #Management
    type = ""
    directattach = false
    privateip = false
    acls {
      matches { ### Outbound rule 
        type = "ip"
        value = "0.0.0.0/0"
      }
    }
    acls { 
      matches { ### Inbound rules & port mappings
        type = "ip"
        value = "0.0.0.0/0"
      }
      actions {
        portmap = true
        portmapto {
          app_port = 22 #Internal App port
        }
      }
      matches {
        type = "protocol"
        value = "tcp"
      }
      matches {
        type = "lport"
        value = 10022  ### External Edge node port
     }
      matches {
        type = "ip"
        value = "0.0.0.0/0"
     }
    }
        acls { 
      matches { ### Mapping inbound port 10443-443
        type = "ip"
        value = "0.0.0.0/0"
      }
      actions {
        portmap = true
        portmapto {
          app_port = 443 #Internal App port
        }
      }
      matches {
        type = "protocol"
        value = "tcp"
      }
      matches {
        type = "lport"
        value = 10443 #External Edge node port
     }
      matches {
        type = "ip"
        value = "0.0.0.0/0"
     }
    }
   } 
  interfaces {
    name = "eth1" #WAN
    type = ""
    directattach = false
    privateip = false
      acls {
        matches { ### Outbound rule
          type = "ip"
          value = "0.0.0.0/0"
      }
    }
   }
  interfaces {
    name = "eth2" #LAN-1
    type = ""
    directattach = false
    privateip = false
      acls {
        matches { ### Outbound rule
          type = "ip"
          value = "0.0.0.0/0"
        }
      }
   }
  interfaces {
    name = "eth3" #LAN-2
    type = ""
    directattach = false
    privateip = false
      acls {
        matches { ### Outbound rule
          type = "ip"
          value = "0.0.0.0/0"
        }
      }
   }
  vmmode = "HV_HVM"
  enablevnc = true

  resources {
    name = "resourceType"
    value = "custom"
  }
  resources {
    name = "cpus"
    value = 2
  }
  resources {
    name = "memory"
    value = 4000000
  }
  resources {
    name = "storage"
    value = 40971520
  }
  configuration {
    custom_config {
      add = true
      name = "cloud-config"
      override = true
      template = ""      
    }
   }
  app_type = "APP_TYPE_VM" 
  deployment_type = "DEPLOYMENT_TYPE_STAND_ALONE"
  cpu_pinning_enabled = false
 }
  user_defined_version = "7.4.3"
  origin_type = "ORIGIN_LOCAL"
}

resource "zedcloud_application" "tf_ubuntu_app_1" {
  name = "TF-UBUNTU-APP"
  title = "TF-UBUNTU-APP"
  networks = 1
  manifest {
    ac_kind = "VMManifest"
    ac_version = "1.2.0"
    name = "TF-VM-APP"
    app_type = "APP_TYPE_VM"
    deployment_type = "DEPLOYMENT_TYPE_STAND_ALONE"
    cpu_pinning_enabled = false
    resources {
      name = "cpus"
      value = 2
    }
    resources {
      name  = "memory"
      value = 2097152
    }
  owner {
    user        = "Manny Calero"
    company     = "Zededa"
    website     = "www.zededa.com"
    email       = "manny@zededa.com"
  }
  desc {
    app_category = "APP_CATEGORY_OPERATING_SYSTEM"
    category     = "APP_CATEGORY_OPERATING_SYSTEM"
     logo        = {
       url       = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Ubuntu-logo-2022.svg/250px-Ubuntu-logo-2022.svg.png" 
      }
    } 
  images {
    imagename = zedcloud_image.ubuntu_noble_image.name
    imageid = zedcloud_image.ubuntu_noble_image.id
    imageformat = "QCOW2"
    cleartext = false
    drvtype = "HDD"
    ignorepurge = true
    maxsize = 20971520
    target = "Disk"
    }
  interfaces {
    name = "eth0"
    type = ""
    directattach = false
    privateip = false
   acls {
      matches { ### Outbound rule 
        type = "ip"
        value = "0.0.0.0/0"
      }
    }
   } 
  vmmode = "HV_HVM"
  enablevnc = true

  configuration {
    custom_config {
      add = true
      name = "cloud-config"
      override = true
      template = ""      
    }
   }
    resources {
      name = "storage"
      value = 20971520
    }
 }
  user_defined_version = "24.04"
  origin_type = "ORIGIN_LOCAL"
  project_access_list = []
}

resource "zedcloud_application" "tf_ubuntu_k3s_app" {
  name = "TF-UBUNTU-K3S"
  title = "TF-UBUNTU-K3S"
  networks = 1
  manifest {
    ac_kind = "VMManifest"
    ac_version = "1.2.0"
    name = "TF-VM-APP"
    app_type = "APP_TYPE_VM"
    deployment_type = "DEPLOYMENT_TYPE_STAND_ALONE"
    cpu_pinning_enabled = false
    resources {
      name = "cpus"
      value = 2
    }
    resources {
      name  = "memory"
      value = 2097152
    }
  owner {
    user        = "Manny Calero"
    company     = "Zededa"
    website     = "www.zededa.com"
    email       = "manny@zededa.com"
  }
  desc {
    app_category = "APP_CATEGORY_OPERATING_SYSTEM"
    category     = "APP_CATEGORY_OPERATING_SYSTEM"
     logo        = {
       url       = "https://avatars.githubusercontent.com/u/49319725?s=48&v=4" 
      }
    } 
  images {
    imagename = zedcloud_image.ubuntu_noble_image.name
    imageid = zedcloud_image.ubuntu_noble_image.id
    imageformat = "QCOW2"
    cleartext = false
    drvtype = "HDD"
    ignorepurge = true
    maxsize = 20971520
    target = "Disk"
    }
  interfaces {
    name = "eth0"
    type = ""
    directattach = false
    privateip = false
   acls {
      matches { ### Outbound rule 
        type = "ip"
        value = "0.0.0.0/0"
      }
    }
   } 
  vmmode = "HV_HVM"
  enablevnc = true

  configuration {
    custom_config {
      add = true
      name = "cloud-config"
      override = true
      template = ""      
    }
   }
    resources {
      name = "storage"
      value = 20971520
    }
 }
  user_defined_version = "24.04"
  origin_type = "ORIGIN_LOCAL"
  project_access_list = []
}

# =================== Instances ===========================
# ---------- Create Firewall VM1 Deploy ----------
resource "zedcloud_application_instance" "tf_fw_deploy" {
  name              = "TF-DEMO-FW"
  title             = "TF-DEMO-FW"
  project_id        = zedcloud_project.demo_project_zededa_1.id
  app_id            = zedcloud_application.demo_forgigate_app.id
  activate          = true
  custom_config {
    add             = true
    allow_storage_resize = true
    field_delimiter = "@@@"
    name            = "cloud-config"
    override        = true
    template        = base64encode(file("./cinit/fortinet-cloud-init.txt"))
  }
  device_id         = zedcloud_edgenode.demo_edge_node_1.id
  drives {
    imagename       = zedcloud_image.tf_demo_fw_image.name
    cleartext       = false
    ignorepurge     = true
    maxsize         = 20000000
    preserve        = false
    target          = "Disk"
    drvtype         = "HDD"
    readonly        = false
  }
  interfaces {
    intfname = "eth0"
    intforder = 1
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.demo_mgt_net.name
    privateip = false
  }
  interfaces {
    intfname = "eth1"
    intforder = 2
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.demo_wan_net.name
    privateip = false
  }
  interfaces {
    intfname = "eth2"
    intforder = 3
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.demo_lan_1_net.name
    privateip = false
  }
  interfaces {
    intfname = "eth3"
    intforder = 4
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.demo_lan_2_net.name
    privateip = false
  }
}

#---------- Create Ubuntu VM1 Deploy ----------
resource "zedcloud_application_instance" "tf_vm_2_deploy" {
  name              = "VM-1"
  title             = "VM-1"
  project_id        = zedcloud_project.demo_project_zededa_1.id
  app_id            = zedcloud_application.tf_ubuntu_app_1.id
  activate          = true
  custom_config {
    add             = true
    allow_storage_resize = true
    field_delimiter = "@@@"
    name            = "cloud-config"
    override        = true
    template        = base64encode(file("./cinit/vm1-cloud-init.txt"))
  }
  device_id         = zedcloud_edgenode.demo_edge_node_1.id
  drives {
    imagename       = zedcloud_image.ubuntu_noble_image.name
    cleartext       = false
    ignorepurge     = true
    maxsize         = 20000000
    preserve        = false
    target          = "Disk"
    drvtype         = "HDD"
    readonly        = false
  }
  interfaces {
    intfname = "eth0"
    intforder = 1
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.demo_lan_1_net.name
    privateip = false
  }
}

resource "zedcloud_application_instance" "tf_vm_3_deploy" {
  name              = "VM-2"
  title             = "VM-2"
  project_id        = zedcloud_project.demo_project_zededa_1.id
  app_id            = zedcloud_application.tf_ubuntu_app_1.id
  activate          = true
  custom_config {
    add             = true
    allow_storage_resize = true
    field_delimiter = "@@@"
    name            = "cloud-config"
    override        = true
    template        = base64encode(file("./cinit/vm2-cloud-init.txt"))
  }
  device_id         = zedcloud_edgenode.demo_edge_node_1.id
  drives {
    imagename       = zedcloud_image.ubuntu_noble_image.name
    cleartext       = false
    ignorepurge     = true
    maxsize         = 20000000
    preserve        = false
    target          = "Disk"
    drvtype         = "HDD"
    readonly        = false
  }
  interfaces {
    intfname = "eth0"
    intforder = 1
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.demo_lan_2_net.name
    privateip = false
  }
}

#---------- Create k3s App Runtime ----------
resource "zedcloud_application_instance" "tf_k3s_1_deploy" {
  name              = "K3S-VM-1"
  title             = "K3S-VM-1"
  project_id        = zedcloud_project.demo_project_zededa_1.id
  app_id            = zedcloud_application.tf_ubuntu_k3s_app.id
  activate          = true
  custom_config {
    add             = true
    allow_storage_resize = true
    field_delimiter = "@@@"
    name            = "cloud-config"
    override        = true
    template        = base64encode(file("./cinit/k3s_1.txt"))
  }
  device_id         = zedcloud_edgenode.demo_edge_node_1.id
  drives {
    imagename       = zedcloud_image.ubuntu_noble_image.name
    cleartext       = false
    ignorepurge     = true
    maxsize         = 20971520
    preserve        = false
    target          = "Disk"
    drvtype         = "HDD"
    readonly        = false
  }
  interfaces {
    intfname = "eth0"
    intforder = 1
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.demo_lan_2_net.name
    privateip = false
  }
}

