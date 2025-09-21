# Flask → AWS EKS CI/CD

This project demonstrates how to provision AWS infrastructure with Terraform, containerize a Python Flask app, and deploy it to an Amazon EKS cluster using Jenkins CI/CD.

---

## Repository Structure

```
PRT/
├─ terraform/              # Infrastructure provisioning
│  ├─ main.tf
│  ├─ variables.tf
│  ├─ outputs.tf
│  ├─ providers.tf
│  └─ versions.tf
|  └─ terraform.tfvars
├─ k8s/                    # Kubernetes manifests
│  ├─ deployment.yaml
│  ├─ service.yaml
│  ├─ hpa.yaml
│  ├─ pdb.yaml
├─ jenkins/
│  └─ Jenkinsfile          # Jenkins pipeline definition
├─ app/                    # Flask app source
│  ├─ app.py
│  ├─ requirements.txt
│  └─ Dockerfile
└─ README.md
```

---

## ⚙Prerequisites

1. **AWS account** with admin/appropriate permissions.
2. **Terraform 1.0+** installed locally.
3. **AWS CLI v2** installed and configured.
4. **kubectl** installed and configured.
5. **Jenkins server/agent** with:

   * `docker`
   * `awscli`
   * `kubectl`
   * `python` (for running tests)
6. Jenkins must have:

   * AWS credentials stored as `aws-creds`.
   * Environment variables (`AWS_ACCOUNT_ID`, `AWS_REGION`, `CLUSTER_NAME`).

---

## Setup Instructions

### 1. Clone this repository

```bash
git clone https://github.com/tanujbhatia24/PRT.git
cd PRT
```

---

### 2. Provision AWS Infrastructure (Terraform)

1. Navigate to the Terraform directory:

```bash
cd terraform
```

2. Create a `terraform.tfvars` file with your values:

```hcl
aws_region             = "ap-south-1"
cluster_name           = "flask-eks-cluster"
vpc_cidr               = "10.0.0.0/16"
public_subnets         = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnets        = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
node_group_desired_capacity = 2
node_group_min_size    = 1
node_group_max_size    = 3
```

3. Initialize and apply Terraform:

```bash
terraform init
terraform apply -auto-approve
```

4. Note the outputs:

   * **cluster\_name**
   * **cluster\_endpoint**
   * **ecr\_repo\_url**

These will be required in later steps.

---

### 3. Flask Application & Docker Image

1. The app is in `app/app.py`. You can modify routes as needed.
2. The `Dockerfile` is configured for security (non-root user).
3. If you change the app port or entrypoint, update:

   * `Dockerfile` `EXPOSE`
   * `k8s/deployment.yaml` `containerPort`
   * `k8s/service.yaml` `targetPort`

---

### 4. Configure Jenkins

1. Go to Jenkins → Manage Jenkins → Credentials → Add credentials.

   * Add `aws-creds` with Access Key ID + Secret Access Key.
2. Create a new Jenkins Pipeline job.
3. Point it to this repository.
4. Add environment variables:

   * `AWS_ACCOUNT_ID` → your AWS account ID (12-digit number).
   * `AWS_REGION` → same region as Terraform.
   * `CLUSTER_NAME` → value from Terraform output.

---

### 5. Run the Jenkins Pipeline

1. The pipeline stages:

   * Checkout code
   * Run unit tests (`pytest`)
   * Build Docker image
   * Push to ECR
   * Update kubeconfig
   * Deploy manifests to EKS

2. Confirm the pipeline succeeds.

---

### 6. Deploy to Kubernetes Manually (Optional)

If not using Jenkins, you can deploy manually:

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com

# Build and push image
docker build -t flask-app:latest ./app
docker tag flask-app:latest <ECR_REPO_URL>:latest
docker push <ECR_REPO_URL>:latest

# Update kubeconfig
aws eks --region <AWS_REGION> update-kubeconfig --name <CLUSTER_NAME>

# Deploy
tt
sed "s|REPLACE_IMAGE|<ECR_REPO_URL>:latest|g" k8s/deployment.yaml | kubectl apply -f -
kubectl apply -f k8s/service.yaml
```

---

### 7. Verify Deployment

```bash
kubectl get pods
kubectl get svc flask-app-service
```

Access the service via the `EXTERNAL-IP` of the LoadBalancer.

---

## What You Need to Change

* **Terraform variables** (`terraform/variables.tf` or `terraform.tfvars`): region, cluster name, VPC CIDR, subnets.
* **Jenkinsfile**: update `ECR_REPO` with your account ID and region if not passed as env variables.
* **Kubernetes manifests**:

  * Replace `REPLACE_IMAGE` with your actual ECR image URL.
  * Adjust CPU/Memory requests and limits as per your workload.
* **Flask app** (`app/app.py`): update logic, routes, or dependencies in `requirements.txt`.

---

## Security Best Practices

* Do not hardcode AWS credentials. Use Jenkins credentials or IAM roles.
* Enable image scanning in ECR.
* Run containers as non-root (already configured).
* Use resource limits in Kubernetes.
* Add NetworkPolicies to restrict access.
* Store secrets in Kubernetes Secrets or AWS Secrets Manager.

---

## Summary

This project provides a **ready-to-use CI/CD pipeline** to deploy a Flask app to EKS with Terraform, Jenkins, and Kubernetes. Follow the steps above, replace placeholder values, and you’ll have a reproducible setup that can be extended for production workloads.
