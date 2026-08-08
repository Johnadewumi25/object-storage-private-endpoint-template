# OCI Object Storage Private Endpoint Terraform Template

This repository provides an English, Terraform-managed reference implementation for an OCI Object Storage private endpoint. It was created after a request to deploy private endpoints consistently in `ptnonprod` and `ptprod`, following a manually configured proof of concept in `paracepoc`.

OCI documents the Object Storage private endpoint service, but the Terraform resource can be difficult to discover in the Registry. The resource used by this template is [`oci_objectstorage_private_endpoint`](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_private_endpoint). The implementation also uses an access target to limit the endpoint to the bucket created by the template.

## Background and references

- [OCI Object Storage private endpoints](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/private-endpoints.htm) — official service documentation.
- [Oracle example: Private Endpoint for OCI Object Storage with Terraform](https://blogs.oracle.com/lad-cloud-experts-pt/private-endpoint-oci-object-storage-terraform) — supporting implementation reference (written in Portuguese); this repository provides the English customer-facing guide.
- [OCI Terraform provider source](https://github.com/oracle/terraform-provider-oci) — provider implementation and issue-tracking location when Registry documentation needs improvement.

## Customer reference article

For a customer-ready walkthrough, including architecture, deployment options, verification, security considerations, and troubleshooting, see [Private Access to OCI Object Storage with Terraform](article/index.md).

Use this template once per target environment (for example, `ptnonprod` and `ptprod`) with environment-specific Terraform variables and state. Do not reuse state between environments.

## What this template creates

It creates:

- one VCN
- one private subnet
- one security list that allows HTTPS from the VCN CIDR
- one private Object Storage bucket
- one Object Storage private endpoint
- one access target scoped to the created bucket

No OCI credentials, OCIDs, Terraform state files, or local provider cache files are included in this template.

## Requirements

- Terraform 1.5 or later
- OCI Terraform provider 6.31.0 or later
- OCI CLI/API credentials configured locally
- An OCI compartment where the user can create networking and Object Storage resources

The OCI principal running Terraform needs permissions similar to:

```text
Allow group <group-name> to manage objectstorage-private-endpoint in tenancy
Allow group <group-name> to manage virtual-network-family in tenancy
Allow group <group-name> to manage buckets in compartment <compartment-name>
Allow group <group-name> to manage objects in compartment <compartment-name>
```

## Configure

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

On Windows PowerShell:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set these values for your environment:

```hcl
oci_profile      = "DEFAULT"
region           = "us-ashburn-1"
tenancy_ocid     = "ocid1.tenancy.oc1..example"
compartment_ocid = "ocid1.compartment.oc1..example"
```

If the default CIDR ranges overlap with existing networks, change:

```hcl
vcn_cidr    = "10.42.0.0/16"
subnet_cidr = "10.42.1.0/24"
```

## Deploy

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## Verify the Private Endpoint

After `terraform apply`, Terraform prints a command like this:

```bash
oci os private-endpoint get --namespace-name <namespace> --pe-name tf-os-pe-test-pe
```

The private endpoint should show:

```text
lifecycle-state: ACTIVE
private-endpoint-ip: <private-ip>
fqdns.prefix-fqdns.object-storage-api-fqdn: <private-object-storage-fqdn>
```

In the OCI Console, go to:

```text
Storage > Object Storage & Archive Storage > Private Endpoints
```

Select the same compartment used in `terraform.tfvars`, then open the private endpoint and review:

- Details
- FQDNs
- Access Targets
- Tags

## Test Object Access Through the Private Endpoint

Run this from a compute instance or host that can resolve and route to the private endpoint in the VCN.

Create a test file:

```bash
echo "hello private endpoint" > test.txt
```

Upload through the private Object Storage API FQDN from the Terraform output:

```bash
oci os object put \
  --namespace <namespace> \
  --bucket-name tf-os-pe-test-bucket \
  --name test.txt \
  --file ./test.txt \
  --endpoint https://<object-storage-api-fqdn-from-terraform-output>
```

Download it back:

```bash
oci os object get \
  --namespace <namespace> \
  --bucket-name tf-os-pe-test-bucket \
  --name test.txt \
  --file ./downloaded.txt \
  --endpoint https://<object-storage-api-fqdn-from-terraform-output>
```

## Cleanup

```bash
terraform destroy
```
