#   1. Deploy IPAM
#   Create the IPAM resource with operating regions in us-east-1 and us-east-2
resource "awscc_ec2_ipam" "main" {
  operating_regions = [
    {
      region_name = "ap-south-1"
    },
    {
      region_name = "ap-southeast-1"
    }
  ]
  tags = [{
    key   = "Name"
    value = "global-ipam"
  }]
}

#   2. Deploy IPAM Root Pool
#   Create the Root IPAM Pool resource with address_family set to ipv4.
#   Reference the attribute private_default_scope_id from the awscc_ec2_ipam.main resource to set the 
#   ipam_scope_id attribute.
resource "awscc_ec2_ipam_pool" "root" {
  address_family = "ipv4"
  ipam_scope_id  = awscc_ec2_ipam.main.private_default_scope_id
  auto_import    = false

  provisioned_cidrs = [
    {
      cidr = "10.0.0.0/16"
    }
  ]

  tags = [{
    key   = "Name"
    value = "top-level-pool"
  }]
}

#   3. Deploy IPAM Child Pools
#   In this section we will create two IPAM pools. One pool will manage CIDRs in the ap-south-1 region,
#   and the other pool will manage CIDRs in the ap-outheast-1 region.

#    IPAM Pool that manages the us-east-1 region:
resource "awscc_ec2_ipam_pool" "ap-south-1" {
  address_family      = "ipv4"
  auto_import         = false
  ipam_scope_id       = awscc_ec2_ipam.main.private_default_scope_id
  locale              = "ap-south-1"
  source_ipam_pool_id = awscc_ec2_ipam_pool.root.ipam_pool_id
  provisioned_cidrs = [{
    cidr = "10.0.0.0/17"
  }]
  tags = [{
    key   = "Name"
    value = "regional-pool-ap-south-1"
  }]
}

#  IPAM Pool that manages the ap-southeast-1 region:
resource "awscc_ec2_ipam_pool" "ap-southeast-1" {
  address_family      = "ipv4"
  auto_import         = false
  ipam_scope_id       = awscc_ec2_ipam.main.private_default_scope_id
  locale              = "ap-southeast-1"
  source_ipam_pool_id = awscc_ec2_ipam_pool.root.ipam_pool_id
  provisioned_cidrs = [{
    cidr = "10.0.128.0/17"
  }]
  tags = [{
    key   = "Name"
    value = "regional-pool-ap-southeast-1"
  }]
}

#   4. Deploy a VPC in the ap-south-1 region
#   Before we used the awscc provider to create the IPAM resources.
#   Now we will use the aws provider to create VPCs. 
#   Both VPCs will retrieve their CIDR allocation from the respective region's IPAM pool.

#   Create a vpc resource in ap-south-1
#   This will read attributes from resources created in a different provider in a new resource definition.
resource "aws_vpc" "apsouth1" {
  ipv4_ipam_pool_id   = awscc_ec2_ipam_pool.ap-south-1.id
  ipv4_netmask_length = 24
  tags = {
    Name = "ap-south-1"
  }
}

#   5. Deploy a VPC in the ap-southeast-1 region
#   Create a vpc resource in ap-southeast-1
resource "aws_vpc" "apsoutheast1" {
  provider            = aws.southeast1
  ipv4_ipam_pool_id   = awscc_ec2_ipam_pool.ap-southeast-1.id
  ipv4_netmask_length = 24
  tags = {
    Name = "ap-southeast-1"
  }
}

/*
IPAM resources that manage VPCs have a safety mechanism to limit unintentional freeing of CIDR ranges. 
This safety mechanism will not allow you to immediately delete IPAM resources after an associated VPC 
has been deleted.

We can bypass this safety mechanism by running the "delete-ipam" CLI command with the "--cascade" flag. 
This enables you to quickly delete an IPAM, private scopes, pools in private scopes, 
and any allocations in the pools in private scopes.

Replacing the string REPLACE_WITH_IPAM_ID with the IPAM ID

    aws ec2 delete-ipam --cascade --ipam-id REPLACE_WITH_IPAM_ID

We will now use the terraform CLI to destroy the other resources, 
and we will run the "terraform destroy" command.

    terraform destroy --auto-approve

*/


