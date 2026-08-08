variable "oci_profile" {
  description = "OCI CLI config profile to use from ~/.oci/config."
  type        = string
  default     = "DEFAULT"
}

variable "region" {
  description = "OCI region for the deployment."
  type        = string
}

variable "tenancy_ocid" {
  description = "Tenancy OCID, used to read the Object Storage namespace."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where the test resources will be created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for all created resources."
  type        = string
  default     = "tf-os-pe-test"
}

variable "vcn_cidr" {
  description = "CIDR block for the test VCN."
  type        = string
  default     = "10.42.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the private endpoint subnet."
  type        = string
  default     = "10.42.1.0/24"
}

variable "private_endpoint_ip" {
  description = "Optional fixed private IP for the Object Storage private endpoint. Leave null to let OCI assign one."
  type        = string
  default     = null
}

variable "additional_prefixes" {
  description = "Optional additional DNS prefixes for the Object Storage private endpoint."
  type        = list(string)
  default     = []
}

variable "freeform_tags" {
  description = "Freeform tags to apply to created resources."
  type        = map(string)
  default = {
    purpose = "terraform-objectstorage-private-endpoint-test"
  }
}
