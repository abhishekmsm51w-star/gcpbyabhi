
# Build Global and Regional Load Balancing Solutions: Challenge Lab

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

# Build Global and Regional Load Balancing Solutions: Challenge Lab

> **Challenge Lab Guide**
>
> Learn how to configure and validate a Regional Internal Proxy Network Load Balancer in Google Cloud using Managed Instance Groups, Health Checks, Firewall Rules, and Backend Services.

---

## 🤝 Support

If this guide helped you, consider subscribing to **Dr Abhishek** for more Google Cloud Skills Boost solutions, challenge labs, and cloud learning resources.

### 📺 YouTube
https://www.youtube.com/@drabhishek.5460

---

## ⚠️ Educational Disclaimer

This guide and any accompanying scripts are provided solely for educational purposes. They are designed to help learners understand Google Cloud services, networking concepts, and challenge lab workflows.

Before running any script, review the commands carefully to understand the resources being created or modified. Users are responsible for ensuring compliance with Google Cloud Skills Boost Terms of Service and all applicable platform policies.

The objective of this content is to support learning and hands-on practice—not to bypass assessments or violate any service guidelines.

---

# Task 1: Configure a Regional Internal Proxy Network Load Balancer

In this task, you will deploy and validate a **Regional Internal Proxy Network Load Balancer (NLB)**. The process includes creating a regional managed instance group, configuring firewall rules, creating health checks, reserving an internal IP address, and validating connectivity from a client VM.

---

## Step 1: Create a Regional Managed Instance Group

Navigate to:

**Compute Engine → Instance Groups → Create Instance Group**

Configure the following settings:

| Setting | Value |
|----------|----------|
| Name | `mig-proxy-internal` |
| Instance Template | `template-proxy-internal` |
| Region | Region B |

After creating the instance group, add a named port:

| Name | Port |
|--------|------|
| tcp80 | 80 |

---

## Step 2: Configure Firewall Rules

### Allow Health Check Traffic

```bash
gcloud compute firewall-rules create fw-allow-hc-proxy-internal \
  --network=lb-network \
  --action=ALLOW \
  --direction=INGRESS \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=tag-proxy-internal \
  --rules=tcp:80
```

### Allow Internal Proxy Traffic

```bash
gcloud compute firewall-rules create fw-allow-proxy-subnet-internal \
  --network=lb-network \
  --action=ALLOW \
  --direction=INGRESS \
  --source-ranges=10.129.0.0/23 \
  --target-tags=tag-proxy-internal \
  --rules=tcp:80
```

---

## Step 3: Create a TCP Health Check

```bash
read -p "Enter REGION_A: " REGION_A
read -p "Enter REGION_B: " REGION_B

echo "export REGION_A=$REGION_A" >> ~/.bashrc
echo "export REGION_B=$REGION_B" >> ~/.bashrc

source ~/.bashrc

gcloud compute health-checks create tcp hc-internal-proxy \
    --region=$REGION_B \
    --port=80
```

---

## Step 4: Reserve an Internal Static IP Address

Navigate to:

**VPC Network → IP Addresses → Reserve Internal IP Address**

Configure:

| Setting | Value |
|----------|----------|
| Name | `ip-internal-proxy` |
| Region | Region B |
| Network | `lb-network` |
| Subnet | `lb-backend-subnet-region-b` |
| Purpose | Shared Load Balancer VIP |

---

## Step 5: Create the Backend Service

```bash
gcloud compute backend-services create internal-proxy-backend \
    --load-balancing-scheme=INTERNAL_MANAGED \
    --protocol=TCP \
    --region=$REGION_B \
    --health-checks=hc-internal-proxy \
    --health-checks-region=$REGION_B
```

```bash
gcloud compute backend-services add-backend internal-proxy-backend \
    --instance-group=mig-proxy-internal \
    --instance-group-region=$REGION_B \
    --region=$REGION_B
```

---

## Step 6: Create the Internal Proxy Network Load Balancer

Configure the frontend:

| Setting | Value |
|----------|----------|
| Name | `rule-internal-proxy` |
| IP Address | `ip-internal-proxy` |
| Protocol | TCP |
| Port | `110` |
| Global Access | Disabled |

Create the load balancer and wait until the backend becomes healthy.

---

## Step 7: Create a Client VM

```bash
gcloud compute instances create vm-client-internal \
   --zone=${REGION_B}-b \
   --machine-type=e2-micro \
   --network=lb-network \
   --subnet=lb-backend-subnet-region-b \
   --tags=allow-ssh
```

---

## Step 8: Validate Connectivity

Retrieve the internal load balancer IP address:

```bash
LB_IP=$(gcloud compute addresses describe ip-internal-proxy \
    --region=$REGION_B \
    --format="value(address)")

echo $LB_IP
```

SSH into **vm-client-internal** and test the load balancer:

```bash
curl http://[LB_IP]:110
```

If required, execute the helper script:

```bash
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Build%20Global%20and%20Regional%20Load%20Balancing%20Solutions%3A%20Challenge%20Lab/drabhishek.sh

sudo chmod +x drabhishek.sh

./drabhishek.sh
```

Run the validation command again:

```bash
curl http://[LB_IP]:110
```

---

## Verify Progress

Return to the lab interface and click:

**Check My Progress → Create a Regional Internal Proxy NLB**



<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>

<a href="https://t.me/+gBcgRTlZLyM4OGI1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Channel"/>
</a>

<a href="https://t.me/+RujS6mqBFawzZDFl" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Group"/>
</a>

<a href="https://www.whatsapp.com/channel/0029VbCB6SpLo4hdpzFoD73f" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white&labelColor=25D366" alt="WhatsApp Channel"/>
</a>

<a href="https://www.youtube.com/@drabhishek.5460?sub_confirmation=1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Subscribe_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white&labelColor=FF0000" alt="YouTube"/>
</a>

<a href="https://www.instagram.com/drabhishek.5460/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white&labelColor=E4405F" alt="Instagram"/>
</a>

<a href="https://www.facebook.com/people/Dr-Abhishek/61580947955153/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white&labelColor=1877F2" alt="Facebook"/>
</a>

<a href="https://x.com/DAbhishek5460" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_X-000000?style=for-the-badge&logo=x&logoColor=white&labelColor=000000" alt="X (Twitter)"/>
</a>

</div>
