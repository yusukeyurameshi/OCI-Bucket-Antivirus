resource "oci_streaming_stream" "StreamObjAntiVirus" {
  name = "StreamObjAntiVirus"
  partitions = 0
  compartment_id = oci_identity_compartment.ObjAntiVirus.id
}

resource "oci_events_rule" "RuObjAntiVirus" {
  compartment_id = compartment_ocid
  display_name = "RuObjAntiVirus"
  condition = "com.oraclecloud.objectstorage.createobject"
  actions {
    actions {
      action_type = "OSS"
      is_enabled = True
      stream_id = oci_streaming_stream.StreamObjAntiVirus.id
    }
  }
  is_enabled = True
  depends_on = [oci_streaming_stream.StreamObjAntiVirus]
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
    user_data = base64encode(file("./cloud-init/cloud-init.sh"))
    StreamID  = oci_streaming_stream.StreamObjAntiVirus
  }

}