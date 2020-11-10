resource "oci_streaming_stream" "StreamObjAntiVirus" {
  name = "StreamObjAntiVirus"
  partitions = 1
  compartment_id = oci_identity_compartment.ObjAntiVirus.id
}

resource "oci_events_rule" "RuObjAntiVirus" {
  compartment_id = var.compartment_ocid
  display_name = "RuObjAntiVirus"
  condition = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\"],\"data\":{}}"
  actions {
    actions {
      action_type = "OSS"
      is_enabled = true
      stream_id = oci_streaming_stream.StreamObjAntiVirus.id
    }
  }
  is_enabled = true
}

resource "oci_core_instance" "ObjAntiVirus-inst" {
  depends_on = [oci_streaming_stream.StreamObjAntiVirus]
  display_name        = "Obj.Stg.Antivirus"
  compartment_id      = oci_identity_compartment.ObjAntiVirus.id
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")
  shape               = var.Instance_shape_free

  source_details {
    source_id   = lookup(data.oci_core_images.OLImageOCID.images[0], "id")
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.ObjAntiVirus_subnet_public.id
    hostname_label   = "CostControl"
    assign_public_ip = "true"
  }

  metadata = {
    ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAnBQLIGi93bsc8e6N6tWxH5+9O/03BePMvnEYTvJ+eOfS6TD+zxgTr/TDCZwZ0jsYx4wWMfwUErNpKiFTB87pra/5B4a1X4mhst/a+vUY4iH0SlYYZrejCC3UNfWVfAel2wRZLnl/tWzgy+pj3+NAGkl+92Og4/YhvMflKTZMmceUXOPXKwgzeuY0P/9N7WdNz60CO4XKUX8g81meH655tPVBicpKTsAFTM5HoiSgfF1cK+MHu8Uj4NvV9wyF+Tp3SZsVqukHdmZDIgEo5vJYUpMxGW0XQuaJrMGHdUbDLNBCLsZMvqA6DwlA9y6WsoUw0rESEwMtNUL6r7OsXP44Mw== rsa-key-20181027"
    user_data           = base64encode(file("./cloud-init/cloud-init.sh"))
    StreamID            = oci_streaming_stream.StreamObjAntiVirus.id
  }

}