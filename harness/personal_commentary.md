Work so far:

- Harness project setup with all setup work logged as issues. Paperclip is then essentially self updating / building itself - all changes which utilise the paperclip API (I.E will change DB state - but are not a code change) are enforced as scriptable events via the scripts directory (see scripts/README.md) with the AGENT.md enforcing the policy. This means that future harness users can easily use the same scripts to setup their own harness.

Cool features / points of interest:

- The fact every agent/role can be a different model is extremely powerful. We can define codex as the CEO / planner, whilst using claude as the builder / reviewer / tester / etc.
  - In the future we might want a model specifically for image gen, audio gen, video gen, etc - paperclip makes this extremely easy to manage.
