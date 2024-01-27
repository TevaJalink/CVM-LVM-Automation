The CVM-LVM pipline repo contains the code for the migration of personal user machines from on-prem to AWS EC2.
By simplifing the process, both helpdesk teams and engineering teams are able to use the pipeline to migrate users machine to AWS:
1. helpdesk teams - are able to manually migrate the users over by schedualing a migration date and running the pipeline by injecting simple input variable.
2. engineering teams - were given a PAT token with sufficiant credentials to invoke the pipeline using ADO API.
