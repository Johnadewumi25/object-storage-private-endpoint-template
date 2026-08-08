output "namespace" {
  value = data.oci_objectstorage_namespace.this.namespace
}

output "bucket_name" {
  value = oci_objectstorage_bucket.test.name
}

output "private_endpoint_name" {
  value = oci_objectstorage_private_endpoint.test.name
}

output "private_endpoint_id" {
  value = oci_objectstorage_private_endpoint.test.id
}

output "private_endpoint_ip" {
  value = oci_objectstorage_private_endpoint.test.private_endpoint_ip
}

output "private_endpoint_fqdns" {
  value = oci_objectstorage_private_endpoint.test.fqdns
}

output "oci_cli_get_private_endpoint_command" {
  value = "oci os private-endpoint get --namespace-name ${data.oci_objectstorage_namespace.this.namespace} --pe-name ${oci_objectstorage_private_endpoint.test.name}"
}
