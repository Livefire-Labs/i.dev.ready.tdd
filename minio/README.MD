# MinIO Quickstart Guide - vSphere 8 Supervisor Service

[![MinIO](./images/minio.logo.svg)]()

---

![alt text](images/shot1.png)

From the Berger Menu Select Workload Management

---
![alt text](images/workload.mangement.png)

In Workload Management Select Services

Click **ADD** under Add new Service
---

![alt text](images/register.service.png)

Click the URL Discover and download available Supervisor Services here.
---

![alt text](images/vsan.dpp.png)

Click the **URL** vSAN Data Persistance Platform (vDPP) Services:
---

![alt text](images/vsan.dpp.2.png)

Click the **URL** for Downlod version: Minio 2.0.10 to download the deployment yaml for the Minio Service.
---
![alt text](images/register.service.png)

Go back to vCenter and click Upload, select the downloaded minio yaml file
---
![alt text](images/new.service.minio.png)

Click **NEXT**

![alt text](images/eula.png)

Accept the **EULA**

Click **FINISH**
---
![alt text](images/manage.service.minio.png)

Once the Service is deployed to vSphere it needs to added to the Supervisor

Click **ACTIONS** under Minio

Select Manage Service
---
![alt text](images/manage.configure.png)

Select your Superviser

Click **NEXT**
---
![alt text](images/manage.review.png)

No Values file for Minio

Click **FINISH**
---
![alt text](images/plugin.deployed.png)

Wait for the Minio Plugin install task to finish
---
![alt text](images/minio.plugin.general.png)

In Workload management slect the **Supervisor --> Configure --> Minio --> General** to confirm that the Service is up and you can get to the vCenter plugin
---
![alt text](images/minio.plugin.tenant.png)

Click in **Minio --> Tenant --> ADD**
---
![alt text](images/create.tenant.name.tenant.png)

Give the Tenant a Name (MetaData)

Enter the vSphere Supervisor Namespace you wish to assign this Tenant to (must match)

Choose the storage class assigned to the Namespace you wish to use for tenant Storage

Click **NEXT**
---
![alt text](images/create.tenant.tenant.size.png)

Configure the Tenant Server size
---
![alt text](images/create.tenant.preview.configuration.png)

Preview your entries

Click **CREATE**
---
![alt text](images/create.tenant.credetials.png)

Make Sure you Download the credentials file. You will not be shown this info again.

Click **FINISH**
---
![alt text](images/minio.tenant.details.1.png)

Select the new Tenant click **DETAILS**

---
![alt text](images/minio.tenant.details.2.png)

Click **HEALTH**

---
![alt text](images/minio.tenant.details.3.png)

Once the Tenant is up and Running click back to **DETAILS**

---
![alt text](images/minio.tenant.details.2.png)

Click the **Console Endpoint URL**

---
![alt text](images/creds.json.file.png)

Find the crentials.json file you downloaded earlier

For Login into the Console "access_key" = **UserID** and "secret_key" = **Password**

---
![alt text](images/object.store.login.1.png)

**Login**

---
![alt text](images/object.store.ui.png)

You are ready to administer the tenant.
