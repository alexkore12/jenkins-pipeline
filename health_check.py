#!/usr/bin/env python3
"""
Health Check Script for jenkins-pipeline
Verifies Jenkins is accessible and pipeline is functional
"""

import os
import sys
import requests
from datetime import datetime

# Configuration
JENKINS_URL = os.getenv("JENKINS_URL", "http://localhost:8080")
JENKINS_USER = os.getenv("JENKINS_USER", "admin")
JENKINS_TOKEN = os.getenv("JENKINS_TOKEN", "")
CHECK_INTERVAL = 60

def check_jenkins_health():
    """Check if Jenkins is responsive"""
    try:
        url = f"{JENKINS_URL}/api/json"
        auth = (JENKINS_USER, JENKINS_TOKEN) if JENKINS_TOKEN else None
        response = requests.get(url, auth=auth, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            return {
                "status": "healthy",
                "mode": data.get("mode"),
                "jobs": data.get("jobs", []).__len__(),
                "timestamp": datetime.utcnow().isoformat()
            }
        else:
            return {"status": "error", "message": f"HTTP {response.status_code}"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

def check_queue():
    """Check build queue"""
    try:
        url = f"{JENKINS_URL}/queue/api/json"
        auth = (JENKINS_USER, JENKINS_TOKEN) if JENKINS_TOKEN else None
        response = requests.get(url, auth=auth, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            return {"queue_length": data.get("items", []).__len__()}
        return {"error": "failed to get queue"}
    except Exception as e:
        return {"error": str(e)}

def main():
    import json
    
    health = {
        "service": "jenkins-pipeline",
        "timestamp": datetime.utcnow().isoformat(),
        "checks": {}
    }
    
    health["checks"]["jenkins"] = check_jenkins_health()
    health["checks"]["queue"] = check_queue()
    
    if health["checks"]["jenkins"]["status"] == "healthy":
        health["status"] = "healthy"
        print(json.dumps(health, indent=2))
        sys.exit(0)
    else:
        health["status"] = "unhealthy"
        print(json.dumps(health, indent=2))
        sys.exit(1)

if __name__ == "__main__":
    main()
