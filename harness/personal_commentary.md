Work so far:

- Harness project setup with all setup work logged as issues. Paperclip is then essentially self updating / building itself - all changes which utilise the paperclip API (I.E will change DB state - but are not a code change) are enforced as scriptable events via the scripts directory (see scripts/README.md) with the AGENT.md enforcing the policy. This means that future harness users can easily use the same scripts to setup their own harness.

Cool features / points of interest:

- Cross provider / model support per agent - we can define codex as the CEO / planner, whilst using claude as the builder / reviewer / tester / etc (or maybe we want to introduce image gen, audio, video etc models), gives us a lot of flexibility and allows us to use the best model for the job.
- Everything has a well documented rest API, and is scriptable - this means that we can easily extend the harness to do more complex things, and automate tests and setup.

Features

- Reviewer must post an approve/block summary in the issue thread based on the PR checklist template.

TODO

- Think about issue sync - right now we have Jira, and GH issues - I like paperclips agent first issue design, but we should probably have a way to sync issues from other systems, do adapters exist for this?
- On the same note - we want all issues to be shared across team members - do we need a shared hosted database, or just an issue sync (with then still running the control plane locally) - needs further thought / discussion.
- On this note - I've tried to put process in place that all updates to the harness which involve data changes should be scriptable - needs testing E2E / some love.
- E2E / regression tests - we should have a way to run e2e tests against the harness.
- Remote hosting.. right now everyone is running their own instance of paperclip.. we should we should perhaps have a hosted version?
