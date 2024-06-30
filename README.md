# Terraform-Project-with-Multiple-Provider


In this module, we will implement Amazon VPC IP Address Manager (IPAM)  that makes it easier for you to plan, track, and monitor IP addresses for your AWS workloads.

Scope of the project :
1. Use Terraform to create AWS resources in a declarative way
2. Use multiple Terraform providers and be able to reference resources between providers
3. Use Terraform to create and manage resources in multiple AWS regions

![image](https://github.com/ShubhamRRana/Terraform-Project-with-Multiple-Provider/assets/96970537/f50aa0e1-0cfa-4eb0-8bff-d9e2da3235e4)

To complete the picture, we will start creating the architecture by its individual components. The sequence of deployments are as follows:

1. Deploy IPAM
2. Deploy IPAM Root Pool
3. Deploy IPAM Child Pools
4. Deploy a VPC in the us-east-1 region
5. Deploy a VPC in the us-east-2 region

All the aditional information is provided in main.tf file.
