The overall plan is to make "lintyyy" a lazy linter for d
the complexity required was underestimated a linter needs some level of parsing abstraction a "semiparser"

in turn dlangs std isnt very good at "searching"

so new std replacement; 3 nested projects; I will be spinning up 3 agents in 3 nested folders

Communication should flow downhill to the child projects "REQUESTS.md"; these requests should be in the form of `[ ] please fix foo`

Parent agents should only add tests and requests, all agents should be practice test driven dev. DO NOT modify code of the child process.
