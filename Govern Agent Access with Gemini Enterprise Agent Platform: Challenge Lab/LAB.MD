```
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
#
# Deploy ONLY the bigquery_agent to Agent Runtime with an Agent Identity.

import os
import sys

from dotenv import load_dotenv

import vertexai
from vertexai._genai import types

# Load .env
load_dotenv()

# CHANGED: Use actual defaults instead of undefined PROJECT_ID variable
project = os.environ.get(
    "GOOGLE_CLOUD_PROJECT",
    "qwiklabs-gcp-04-92bd616a4842",
)

# CHANGED: Use actual default region instead of undefined REGION variable
location = os.environ.get(
    "GOOGLE_CLOUD_LOCATION",
    "us-central1",
)

if not project:
    sys.exit(
        "GOOGLE_CLOUD_PROJECT is not set. "
        "Run: gcloud config set project <PROJECT_ID>"
    )

AGENT_PACKAGE = "bigquery_agent"

# CHANGED: Use string default instead of undefined AGENT_NAME variable
DISPLAY_NAME = os.environ.get(
    "DISPLAY_NAME",
    "BigQuery Invoice Agent",
)

# Import agent
from bigquery_agent.agent import root_agent as local_agent

# Requirements
with open(os.path.join(AGENT_PACKAGE, "requirements.txt")) as f:
    requirements = [
        line.strip()
        for line in f
        if line.strip() and not line.startswith("#")
    ]

vertexai.init(
    project=project,
    location=location,
)

client = vertexai.Client(
    project=project,
    location=location,
)

# CHANGED: Must match bucket created by install.sh
STAGING_BUCKET = f"gs://{project}-bucket"

# CHANGED: Added debugging output
print("Project:", project)
print("Location:", location)
print("Bucket:", STAGING_BUCKET)

config = {
    "display_name": DISPLAY_NAME,

    # CHANGED: Agent Identity deployment
    "identity_type": "AGENT_IDENTITY",

    "staging_bucket": STAGING_BUCKET,
    "python_version": "3.12",
    "requirements": requirements,
    "extra_packages": [f"./{AGENT_PACKAGE}"],
    "env_vars": {
        "GOOGLE_GENAI_USE_VERTEXAI": os.environ.get(
            "GOOGLE_GENAI_USE_VERTEXAI",
            "TRUE",
        ),
        "GOOGLE_CLOUD_LOCATION": location,

        # CHANGED: Use actual model default instead of undefined MODEL_VERSION
        "MODEL": os.environ.get(
            "MODEL",
            "gemini-2.5-flash",
        ),
    },
}

print(
    f"Deploying '{AGENT_PACKAGE}' as "
    f"'{DISPLAY_NAME}' to Agent Runtime "
    f"with an Agent Identity..."
)
print("This typically takes 5-10 minutes.")

# CHANGED: Debug identity type
print("identity_type =", config["identity_type"])
print("identity_type type =", type(config["identity_type"]))

remote_agent = client.agent_engines.create(
    agent=local_agent,
    config=config,
)

print("\nAgent deployed successfully!")
print(f"Resource Name: {remote_agent.api_resource.name}")

print("\n--- ACTION REQUIRED ---")
print(
    "1. In the console, open Agent Runtime "
    "(Agent Platform > Agents > Deployments)"
)
print(
    "   and find this agent's Agent Identity principal."
)
print(
    "2. Grant that principal the roles it needs:"
)
print(
    "   - BigQuery User (roles/bigquery.user)"
)
print(
    "   - BADMASHI NAHI MITR"
)
print(
    "   SUBSCRIBE TO DR ABHISHEK CHANNEL "
)

```
