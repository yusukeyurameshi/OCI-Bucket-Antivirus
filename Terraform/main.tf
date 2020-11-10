resource oci_identity_compartment ObjAntiVirus {
  description = "ObjAntiVirus"
  name = "ObjAntiVirus"
  compartment_id = var.compartment_ocid
}

resource oci_identity_dynamic_group DynObjAntiVirus {
  depends_on = [oci_core_instance.ObjAntiVirus-inst]
  compartment_id = var.compartment_ocid
  description = "DynObjAntiVirus"
  matching_rule = join("",["ANY { instance.id = '" , oci_core_instance.ObjAntiVirus-inst.id , "' }"])
  name = "DynObjAntiVirus"
}

resource oci_identity_policy PolObjAntiVirus {
  depends_on = [oci_identity_dynamic_group.DynObjAntiVirus]
  compartment_id = var.compartment_ocid
  description = "PolObjAntiVirus"
  name = "PolObjAntiVirus"
  statements = [
    "Allow dynamic-group DynObjAntiVirus to manage all-resources in tenancy"
  ]
}

resource oci_core_vcn virtual_network {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.ObjAntiVirus.id
  defined_tags   = {}

  display_name = "ObjAntiVirus_vcn"
  dns_label    = "ObjAntiVirus"
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = oci_identity_compartment.ObjAntiVirus.id
}

resource "oci_core_internet_gateway" "internet_gateway" {
  display_name   = "ObjAntiVirus-IGW"
  compartment_id = oci_identity_compartment.ObjAntiVirus.id
  vcn_id         = oci_core_vcn.virtual_network.id
}

resource "oci_core_route_table" "route_table" {
  display_name   = "route_table"
  compartment_id = oci_identity_compartment.ObjAntiVirus.id
  vcn_id         = oci_core_vcn.virtual_network.id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_security_list" "security_list" {
  display_name   = "security_list"
  compartment_id = oci_identity_compartment.ObjAntiVirus.id
  vcn_id         = oci_core_vcn.virtual_network.id

  ingress_security_rules {
    protocol = "6"
    tcp_options {
      max = 22
      min = 22
    }
    source = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "All"
    destination = "0.0.0.0/0"
  }

}

resource oci_core_subnet ObjAntiVirus_subnet_public {
  cidr_block     = "10.0.0.0/24"
  compartment_id = oci_identity_compartment.ObjAntiVirus.id
  defined_tags   = {}

  dhcp_options_id = oci_core_vcn.virtual_network.default_dhcp_options_id
  display_name    = "PubSub"
  dns_label       = "ObjAntiVirus"

  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_route_table.route_table.id

  security_list_ids = [
    oci_core_security_list.security_list.id,
  ]

  vcn_id = oci_core_vcn.virtual_network.id
}
