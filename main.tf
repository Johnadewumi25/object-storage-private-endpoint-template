locals {
  bucket_name           = "${var.name_prefix}-bucket"
  private_endpoint_name = "${var.name_prefix}-pe"
  private_endpoint_dns  = "${var.name_prefix}-pe"
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_vcn" "test" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "${var.name_prefix}-vcn"
  dns_label      = "tfospe"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_security_list" "private_endpoint" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.test.id
  display_name   = "${var.name_prefix}-sl"
  freeform_tags  = var.freeform_tags

  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr

    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "private_endpoint" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.test.id
  cidr_block                 = var.subnet_cidr
  display_name               = "${var.name_prefix}-subnet"
  dns_label                  = "pe"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.private_endpoint.id]
  freeform_tags              = var.freeform_tags
}

resource "oci_objectstorage_bucket" "test" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = local.bucket_name
  access_type    = "NoPublicAccess"
  freeform_tags  = var.freeform_tags
}

resource "oci_objectstorage_private_endpoint" "test" {
  compartment_id = var.compartment_ocid
  name           = local.private_endpoint_name
  namespace      = data.oci_objectstorage_namespace.this.namespace
  subnet_id      = oci_core_subnet.private_endpoint.id
  prefix         = local.private_endpoint_dns

  access_targets {
    namespace      = data.oci_objectstorage_namespace.this.namespace
    compartment_id = var.compartment_ocid
    bucket         = oci_objectstorage_bucket.test.name
  }

  private_endpoint_ip = var.private_endpoint_ip
  additional_prefixes = var.additional_prefixes
  freeform_tags       = var.freeform_tags
}
