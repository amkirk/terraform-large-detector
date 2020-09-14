# Large Detector Monitoring
This Terraform file can be used to create a dashboard group, dashboard, and detector that will alert when a detector has too many MTS. Please identify the large detector and split it into multiple smaller detectors.
## Before you get started
Update the main.tf file with your authtoken and desired notification settings.
> auth_token = "<<<YOURTOKENHERE>>>" <br/>
> notifications = ["Email,your-email-address@bar.com"]