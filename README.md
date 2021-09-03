# Preface
The goal of this project was to produce a maintainable, flexible, simple website using infrastructure as code. To follow AWS best practices, this project uses a nuance of the launch configuration called a launch template. AWS strongly recommends that we do not use launch configurations. The workload is accessible from this [DNS name](http://yes-web-707066843.us-east-2.elb.amazonaws.com/), which Amazon has assigned to the load balancer defined in this workload.
Here's a brief overview of the archetectural considerations that drove the workload's design:

- **Security** - Implemented least privilege by granting only the permissions needed to fulfill requirements. Automated infrastructure management to help keep people away from data.
- **Reliability** - Architected the workload to handle changes in demand and designed it to detect failure and automatically heal itself. 
- **Cost Optimization** - Tagged workload resources in order to create cost allocation tags that will ensure the receipt of meaningful billing information in cost allocation reports.
- **Performance Efficiency** - Added a CloudWatch alarm to identify and help remediate performance issues.
- **Operational Excellence** - Established an operations metric defining a target utilzation value.
