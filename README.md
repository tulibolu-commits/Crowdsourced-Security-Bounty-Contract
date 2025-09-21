# Crowdsourced Security Bounty Contract

A comprehensive Clarity smart contract platform enabling security researchers to collaboratively discover vulnerabilities while establishing transparent reputation metrics through community-driven assessment mechanisms.

## Overview

This contract facilitates a decentralized security bounty ecosystem where organizations can post security challenges, researchers can submit solutions, and the community can evaluate the quality of accepted submissions through a sophisticated rating system.

## Core Features

### Bounty Management
- **Create Bounties**: Organizations publish security challenges with reward specifications and optional deadline constraints
- **Escrow System**: Automatic STX token management ensures secure reward distribution to accepted submissions
- **Community Funding**: Multiple contributors can collaboratively fund bounty rewards through the integrated escrow funding system
- **Issuer Controls**: Bounty creators maintain authority to accept solutions and cancel unfunded challenges

### Submission Workflow
- **Solution Submission**: Researchers submit vulnerability reports via IPFS or external URI references
- **Community Voting**: Transparent voting mechanism allows peer evaluation before final acceptance
- **Acceptance Protocol**: Bounty issuers review submissions and trigger reward distribution upon approval

### Rating & Reputation System
- **Quality Assessment**: Community members rate accepted submissions on a 1-5 scale based on impact and thoroughness
- **Reputation Tracking**: Automatic calculation of researcher reputation scores based on submission quality ratings
- **Anti-Gaming Measures**: One rating per user per submission prevents manipulation of reputation metrics
- **Historical Records**: Complete audit trail of all ratings with block height timestamps for transparency

### Collaborative Bounty Funding System
- **Community Contributions**: Multiple users can contribute STX tokens toward specific bounty rewards, enabling distributed funding
- **Contribution Tracking**: Transparent recording of individual contributions with amounts and timestamps
- **Funding Progress**: Real-time monitoring of funding completion percentage and remaining amounts needed
- **Withdrawal Protection**: Contributors can reclaim their STX tokens from unfunded bounties before completion
- **Funding Analytics**: Detailed statistics on contributor counts, funding status, and completion metrics

## Smart Contract Functions

### Public Functions

#### Bounty Operations
```clarity
(create-bounty (title (buff 128)) (description (buff 256)) (reward uint) (deadline-block (optional uint)))
```
Creates a new security bounty with specified parameters and returns unique bounty ID.

```clarity
(fund-bounty (bounty-id uint))
```
Transfers STX tokens to contract escrow for the specified bounty reward pool.

```clarity
(cancel-bounty (bounty-id uint))
```
Allows bounty issuer to cancel unfulfilled bounties and reclaim escrowed funds.

#### Collaborative Funding Operations
```clarity
(initialize-bounty-funding (bounty-id uint) (required-amount uint))
```
Initializes community funding tracking for a specific bounty with target funding amount.

```clarity
(fund-bounty (bounty-id uint) (amount uint))
```
Allows community members to contribute STX tokens toward funding a bounty reward.

```clarity
(withdraw-contribution (bounty-id uint))
```
Enables contributors to reclaim their STX contribution from unfunded bounties.

#### Submission Management
```clarity
(submit-solution (bounty-id uint) (uri (buff 256)))
```
Submits a security vulnerability solution with reference URI for bounty evaluation.

```clarity
(vote-submission (bounty-id uint) (submission-id uint))
```
Enables community voting on submitted solutions before final acceptance decision.

```clarity
(accept-submission (bounty-id uint) (submission-id uint))
```
Accepts a submission and transfers escrowed rewards to the researcher (issuer only).

#### Rating System
```clarity
(rate-submission (bounty-id uint) (submission-id uint) (rating uint))
```
Allows community members to rate accepted submissions on quality (1-5 scale).

### Read-Only Functions

#### Information Retrieval
```clarity
(get-bounty (bounty-id uint))
```
Returns complete bounty information including status and reward details.

```clarity
(get-submission (bounty-id uint) (submission-id uint))
```
Retrieves submission details including acceptance status and vote count.

```clarity
(get-user-reputation-score (user principal))
```
Calculates average reputation score based on all rated accepted submissions.

```clarity
(get-user-reputation-details (user principal))
```
Returns detailed reputation metrics including total ratings and submission count.

```clarity
(get-submission-rating (bounty-id uint) (submission-id uint) (rater principal))
```
Retrieves specific rating given by a user for a particular submission.

#### Funding Information Retrieval
```clarity
(get-funding-status (bounty-id uint))
```
Returns comprehensive funding status including total funded amount and completion status.

```clarity
(get-contributor-info (bounty-id uint) (contributor principal))
```
Retreves detailed contribution information for a specific contributor to a bounty.

```clarity
(get-funding-percentage (bounty-id uint))
```
Calculates the percentage of bounty funding completion (0-100).

```clarity
(get-bounty-funding-summary (bounty-id uint))
```
Provides comprehensive funding analytics including contributors count and remaining needed amount.

## Error Codes

- `ERR-NOT-OWNER (u100)`: Unauthorized access attempt
- `ERR-INVALID (u101)`: Invalid parameter or operation state
- `ERR-NOT-FOUND (u102)`: Requested resource does not exist
- `ERR-ALREADY_SET (u103)`: Contract owner already initialized
- `ERR-ALREADY-RATED (u104)`: User has already rated this submission
- `ERR-NOT-ACCEPTED (u105)`: Attempted to rate non-accepted submission

## Usage Examples

### Creating a Security Bounty
```clarity
;; Create a web application security assessment bounty
(contract-call? .bounty-contract create-bounty 
  "XSS Vulnerability Assessment" 
  "Identify cross-site scripting vulnerabilities in our web application"
  u1000000  ;; 1 STX reward
  (some u52560))  ;; ~1 year deadline
```

### Rating an Accepted Submission
```clarity
;; Rate a high-quality vulnerability report
(contract-call? .bounty-contract rate-submission u1 u123456 u5)  ;; 5/5 rating
```

### Checking Researcher Reputation
```clarity
;; Get researcher's average rating
(contract-call? .bounty-contract get-user-reputation-score 'ST1RESEARCHER...)
```

### Community Bounty Funding
```clarity
;; Initialize funding for a new bounty requiring 5 STX total
(contract-call? .bounty-escrow-funding initialize-bounty-funding u1 u5000000)

;; Community member contributes 2 STX toward the bounty
(contract-call? .bounty-escrow-funding fund-bounty u1 u2000000)

;; Check funding progress
(contract-call? .bounty-escrow-funding get-funding-percentage u1)  ;; Returns 40%

;; Withdraw contribution if bounty is not fully funded
(contract-call? .bounty-escrow-funding withdraw-contribution u1)
```

## Development Setup

### Prerequisites
- Clarinet CLI tool
- Node.js (for testing framework)
- Stacks wallet for testnet interaction

### Installation
```bash
# Clone repository
git clone <repository-url>
cd Crowdsourced-Security-Bounty-Contract

# Install dependencies
npm install

# Verify contract syntax
clarinet check
```

### Testing
```bash
# Run contract tests
clarinet test

# Deploy to local testnet
clarinet integrate
```

## Security Considerations

- **Escrow Safety**: All funds are held in contract-controlled escrow until accepted submissions trigger distribution
- **Access Controls**: Critical functions include appropriate permission checks to prevent unauthorized operations
- **Rating Integrity**: One-per-user rating limits and acceptance requirements prevent reputation manipulation
- **Deadline Enforcement**: Optional deadline parameters provide time-bound security for bounty challenges

## Contributing

Security researchers and developers are encouraged to contribute improvements, additional features, or security enhancements through GitHub pull requests with comprehensive testing coverage.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### Version 1.2.0 (Current)
- **NEW**: Collaborative Bounty Funding System enabling community-driven bounty reward contributions
- **NEW**: Multi-contributor STX token escrow with transparent contribution tracking
- **NEW**: Funding progress monitoring with real-time completion percentage calculations
- **NEW**: Withdrawal protection allowing contributors to reclaim unfunded bounty contributions
- **NEW**: Comprehensive funding analytics with detailed contributor statistics

### Version 1.1.0
- Added comprehensive rating system for accepted submissions
- Implemented reputation tracking for security researchers
- Enhanced submission workflow with quality assessment mechanisms
- Improved error handling with additional validation states
