#  ETL Processing on Google Cloud Using Dataflow and BigQuery (Python) || GSP290 
<div align="center">
<a href="https://www.cloudskillsboost.google/focuses/3460?parent=catalog" target="_blank" rel="noopener noreferrer" style="text-decoration: none;">
    <img src="https://img.shields.io/badge/Open_Lab-Cloud_Skills_Boost-4285F4?style=for-the-badge&logo=google&logoColor=white&labelColor=34A853" alt="Open Lab" style="height: 35px; border-radius: 5px;">
  </a>
</div>

---

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---
## 🛠️ Configuration Steps 🚀

> 💡 **Pro Tip:** *Watch the full video to ensure you achieve full scores on all "Check My Progress" steps!*

<div style="padding: 15px; margin: 10px 0;">
<p><strong>☁️ Run in Cloud Shell:</strong></p>

```bash
curl -LO https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/refs/heads/main/ETL%20Processing%20on%20Google%20Cloud%20Using%20Dataflow%20and%20BigQuery%20Python/abhishek.sh
sudo chmod +x abhishek.sh
./abhishek.sh
```
### Now Follow The video CArefully
```
pip install apache-beam[gcp]==2.59.0

cd dataflow/

python dataflow_python_examples/data_ingestion.py \
  --project=$PROJECT \
  --region=$REGION \
  --runner=DataflowRunner \
  --machine_type=e2-standard-2 \
  --staging_location=gs://$PROJECT/test \
  --temp_location=gs://$PROJECT/test \
  --input=gs://$PROJECT/data_files/head_usa_names.csv \
  --save_main_session

python dataflow_python_examples/data_transformation.py \
  --project=$PROJECT \
  --region=$REGION \
  --runner=DataflowRunner \
  --machine_type=e2-standard-2 \
  --staging_location=gs://$PROJECT/test \
  --temp_location=gs://$PROJECT/test \
  --input=gs://$PROJECT/data_files/head_usa_names.csv \
  --save_main_session

sed -i "s/values = \[x.decode('utf8') for x in csv_row\]/values = \[x for x in csv_row\]/" ./dataflow_python_examples/data_enrichment.py

python dataflow_python_examples/data_enrichment.py \
  --project=$PROJECT \
  --region=$REGION \
  --runner=DataflowRunner \
  --machine_type=e2-standard-2 \
  --staging_location=gs://$PROJECT/test \
  --temp_location=gs://$PROJECT/test \
  --input=gs://$PROJECT/data_files/head_usa_names.csv \
  --save_main_session

# Note: worker_disk_type path looks potentially problematic, often it's just 'pd-ssd' or 'pd-standard'
# If the below fails, try removing the full path from worker_disk_type
python dataflow_python_examples/data_lake_to_mart.py \
  --worker_disk_type="compute.googleapis.com/projects/$PROJECT/zones/$REGION-a/diskTypes/pd-ssd" \ # Adjusted path, assuming zone 'a' exists - might still need tweaking
  --max_num_workers=4 \
  --project=$PROJECT \
  --runner=DataflowRunner \
  --machine_type=e2-standard-2 \
  --staging_location=gs://$PROJECT/test \
  --temp_location=gs://$PROJECT/test \
  --save_main_session \
  --region=$REGION
```

</div>

---
### Congratulations !!!!

Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.  

[![Telegram](https://img.shields.io/badge/Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/+gBcgRTlZLyM4OGI1)  
[![YouTube](https://img.shields.io/badge/Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@drabhishek.5460?sub_confirmation=1)  
[![Instagram](https://img.shields.io/badge/Follow-%23E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/drabhishek.5460/) 
