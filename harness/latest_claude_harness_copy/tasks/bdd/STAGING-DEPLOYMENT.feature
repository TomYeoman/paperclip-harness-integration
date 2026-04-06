Feature: Staging Deployment Quality Gate
  As a Lead agent preparing for a PROMOTE decision
  I want to deploy a GoKit service to staging, run smoke and contract tests, then rollback
  So that I have confidence in the service before promoting to production-facing environments

  Background:
    Given a GoKit service with a service.json at the repository root
    And all milestone PRs have merged and code review is complete
    And the staging environment is reachable

  Scenario 1: Successful pre-release deploy, test, and rollback
    Given Lead triggers "gh workflow run deploy-staging.yml" for the GoKit service
    And Lead records the workflow run ID from "gh run list"
    When Lead spawns an Integration Tester with the run ID, staging endpoint, deploy timestamp, and T+5:00 rollback time
    And Integration Tester executes GET /health and receives a 200 response
    And Integration Tester executes the milestone's primary create-read flow and receives expected responses
    And Integration Tester sends "V: STAGING [milestone-id] Overall: PASS" with evidence before T+5:00
    Then Lead triggers rollback at T+5:00 unconditionally
    And Lead records gate result as PASS and proceeds to PROMOTE

  Scenario 2: Integration Tester executes smoke and contract tests in parallel with rollback countdown
    Given Lead has spawned Integration Tester with staging context at T+0:00
    When Integration Tester begins health check immediately at T+0:00
    And Integration Tester runs the smoke flow at T+0:30
    And Integration Tester runs contract verification at T+1:00
    And all tests complete at T+2:30
    Then Integration Tester sends V: with PASS/FAIL + response body evidence at T+2:30
    And Lead waits until T+5:00 before triggering rollback
    And rollback completes regardless of the test result

  Scenario 3: Unconditional rollback at T+5:00
    Given Integration Tester has sent V: PASS at T+3:00
    When the clock reaches T+5:00
    Then Lead triggers "gh workflow run rollback-staging.yml" unconditionally
    And rollback is not contingent on any test result, approval, or agent response

  Scenario 4: Rollback safety delay when tests are still running
    Given Integration Tester tests are still running at T+4:30
    When Integration Tester detects the T+4:30 threshold
    Then Integration Tester waits 30 seconds (retry 1 of 2)
    And if tests complete within the 30-second window, Integration Tester sends V: with available results
    And if tests do not complete, Integration Tester waits another 30 seconds (retry 2 of 2)
    And after max retries, Integration Tester sends "V: STAGING [milestone-id] Overall: PARTIAL" with partial evidence
    And Lead triggers rollback at T+5:00 regardless
    And Integration Tester does NOT request or expect Lead to delay the rollback

  Scenario 5: Failed test results reported after rollback
    Given Integration Tester has sent "V: STAGING [milestone-id] Overall: FAIL" at T+3:30
    And rollback has been triggered at T+5:00
    When Lead reads the V: result
    Then Lead records gate result as FAIL
    And Lead does NOT proceed to PROMOTE
    And Lead routes the failure to the relevant Builder with the V: evidence
    And a re-gate is required after the fix is deployed to staging
