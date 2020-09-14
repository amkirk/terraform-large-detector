###############################################################################################
# Before applying this Terraform configuration file, fill out these things below:
# - auth_token - set this to the token you use with Terraform
# - notifications - Ensure this is configured to alert the right people in your organization.
###############################################################################################

provider "signalfx" {
  auth_token = "<<<YOURTOKENHERE>>>"
}

resource "signalfx_detector" "aborted_detector" {
  name         = "Detectors Aborted"
  description  = "Triggers when a detector has been aborted because it has too many MTS"
  program_text = <<-EOF
  A = data('sf.org.numDetectorsAborted', rollup='sum').sum(over='5h').publish(label='A')
  B = data('sf.org.abortedDetectors').publish(label='B')
  detect(when(A > threshold(0))).publish('Detector Aborted')
  EOF

  rule {
    description  = "A detector has been aborted."
    severity     = "Major"
    detect_label = "Detector Aborted"
    # Update notifications with your preferred method here. Email and Slack are shown as examples.
    notifications = ["Email,your-email-address@bar.com"]
    #notifications = ["Slack,credentialId,channel"]
    runbook_url        = "https://www.google.com"
    parameterized_body = <<-EOF
   {{#if anomalous}}
    This alert indicates that a detector in your organization has too many MTS and has been aborted. Please identify the large detector and split it into multiple smaller detectors to get it running again.
   {{else}}
    Rule "{{{ruleName}}}" in detector "{{{detectorName}}}" cleared at {{timestamp}}.
    Please verify that the aborted detector is running properly now.
   {{/if}}

   {{#if anomalous}}
   {{#if runbookUrl}}Runbook: {{{runbookUrl}}}{{/if}}
   {{#if tip}}Please view the linked KB article for more information.{{{tip}}}{{/if}}
   {{/if}}
   EOF
  }
}

resource "signalfx_time_chart" "aborted_detectors_chart" {
  name        = "Aborted Detectors"
  description = "This chart identifies any detectors that have been aborted because they have too many MTS."

  program_text = <<-EOF
  A = data('sf.org.numDetectorsAborted', rollup='sum').sum(over='5h').publish(label='Aborted Detectors Counter')
  B = data('sf.org.abortedDetectors').publish(label='Aborted Detectors Events')
  C = alerts(detector_id='${signalfx_detector.aborted_detector.id}').publish(label='C')
  EOF
}

resource "signalfx_dashboard_group" "detectors_group" {
  name        = "Detector Tracking"
  description = "This group can be used to track detector specifics in SignalFx."
}

resource "signalfx_dashboard" "detectors_dashboard" {
  name            = "Aborted Detectors"
  dashboard_group = signalfx_dashboard_group.detectors_group.id
  time_range      = "-1d"
  chart {
    chart_id = signalfx_time_chart.aborted_detectors_chart.id
    width    = 6
  }
}
