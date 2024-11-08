# MinIO Quickstart Guide - vSphere 8 Supervisor Service

[![MinIO](./images/minio.logo.svg)]()

![alt text](images/shot1.png)

From the Berger Menu Select Workload Management

![alt text](images/workload.mangement.png)

In Workload Management Select Services

Click ADD under Add new Service

![alt text](images/register.service.png)

Click the URL Discover and download available Supervisor Services here.

![alt text](images/vsan.dpp.png)

Click the URL vSAN Data Persistance Platform (vDPP) Services:

![alt text](images/vsan.dpp.2.png)

Click the URL for Downlod version: Minio 2.0.10 to download the deployment yaml for the Minio Service.

![alt text](images/register.service.png)

Go back to vCenter and click Upload, select the downloaded minio yaml file

![alt text](images/new.service.minio.png)

Click NEXT

![alt text](images/eula.png)

Accept the EULA

Click FINISH

![alt text](images/manage.service.minio.png)

Once the Service is deployed to vSphere it needs to added to the Supervisor

Click ACTIONS under Minio

Select Manage Service

![alt text](images/manage.configure.png)

Select your Superviser

Click NEXT

![alt text](images/manage.review.png)

No Values file for Minio

Click FINISH

![alt text](images/plugin.deployed.png)

Wait for the Minio Plugin task to fiish

![alt text](images/minio.plugin.general.png)

In Workload management slect the Supervisor --> Configure --> Minio --> General to confirm that the Service is up and you can get to the vCenter plugin

![alt text](images/minio.plugin.tenant.png)

![alt text](images/create.tenant.name.tenant.png)

![alt text](images/create.tenant.tenant.size.png)

![alt text](images/create.tenant.preview.configuration.png)

![alt text](images/create.tenant.credetials.png)

![alt text](images/minio.tenant.details.1.png)

![alt text](images/minio.tenant.details.2.png)

![alt text](images/minio.tenant.details.3.png)

![alt text](images/minio.tenant.details.2.png)

![alt text](images/creds.json.file.png)

![alt text](images/object.store.login.1.png)

![alt text](images/object.store.ui.png)