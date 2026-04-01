# Patch 3 - Hide and Threat Loop

This patch turns the current prototype into a more believable vertical-slice step by adding the missing survival beat:
after the player takes the house key, the house begins an active search and the player must hide until it passes.

## Added
- ThreatDirector system
- threat state in GameState
- player hidden state support
- linen closet hide spot wired into the map
- HUD state + threat readout
- exit door blocks while the threat is active
- new hunt sequence methods in TestLevel

## Flow now
1. Read note
2. Kill room light
3. Open hall door
4. Restore breaker
5. Search bedroom drawer
6. Take house key
7. Active threat begins
8. Hide in linen closet until the search passes
9. Unlock exit
10. Leave house

## Why this matters
The project already had tension and reactions. This patch adds a real survival response,
which makes the house feel more dangerous and gives the slice a stronger payoff.
