# AC Capstone - Upgradeable Merkle Airdrop

[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg)](https://getfoundry.sh/)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.24-blue.svg)](https://soliditylang.org/)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-Contracts-green.svg)](https://openzeppelin.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Author:** Huy Pham
**Project Type:** Educational Capstone & Production-Ready Implementation

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Key Components](#key-components)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Quick Start](#quick-start)
  - [Detailed Workflow](#detailed-workflow)
- [Testing](#testing)
- [Deployed Contracts (Example)](#deployed-contracts-example)
- [Architecture Deep Dive](#architecture-deep-dive)
- [Gas Optimization](#gas-optimization)
- [Development Workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Educational Notes](#educational-notes)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [Resources & Further Reading](#resources--further-reading)

## Overview

This project demonstrates a sophisticated **upgradeable Merkle Airdrop system** built on Ethereum using the **UUPS (Universal Upgradeable Proxy Standard)** pattern. It serves as both an educational capstone project showcasing advanced smart contract patterns and a production-ready implementation suitable for real-world token distribution.

### Purpose

- **Educational**: Demonstrates UUPS upgrade patterns, Merkle proof systems, and production-ready smart contract development
- **Production-Ready**: Implements robust security measures, gas optimizations, and upgrade mechanisms suitable for mainnet deployment

## Key Features

- 🚀 **Merkle Proof-Based Distribution**: Gas-efficient airdrop using Merkle trees
- 🔄 **UUPS Upgradeability**: Seamless contract upgrades without changing proxy address
- 🛡️ **Role-Based Access Control**: Secure upgrade authorization and administrative functions
- ⚡ **Gas Optimized**: Efficient storage and calldata usage
- 🔒 **Double-Claim Prevention**: Built-in protection against duplicate claims
- 📊 **Comprehensive Testing**: Full test coverage with Foundry framework
- 🛠️ **Developer Tools**: Automated deployment, upgrade, and Merkle tree generation scripts

## Architecture

The system uses a **UUPS Proxy Pattern** where:

- **Proxy Contract**: ERC1967 proxy that delegates calls to implementation
- **Implementation Contract**: Contains the actual business logic (MerkleAirdrop.sol)
- **Storage**: All state is stored in the proxy, implementation is stateless
- **Upgrades**: New implementation contracts can be deployed and the proxy updated

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Call     │───▶│   Proxy Contract │───▶│ Implementation  │
│                 │    │   (ERC1967)      │    │   (Logic)       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │   Storage        │
                       │   (State)        │
                       └──────────────────┘
```

## Key Components

### Smart Contracts (`src/`)

#### `BagelToken.sol`
- **Purpose**: ERC20 token with mint/burn role management
- **Features**:
  - Standard ERC20 functionality
  - Role-based minting with `MINT_AND_BURN_ROLE`
  - Access control integration
  - Owner-controlled role assignment

#### `MerkleAirdrop.sol` (V1)
- **Purpose**: Initial implementation with basic claim functionality
- **Features**:
  - Merkle proof verification
  - Token claiming mechanism
  - Double-claim prevention
  - UUPS upgrade preparation

#### `MerkleAirdropV2.sol` (V2)
- **Purpose**: Upgraded version with additional administrative functions
- **New Features**:
  - `setMerkleRoot()`: Update Merkle root for new airdrop rounds
  - `setAirdropToken()`: Change the token being distributed
  - Enhanced event emissions for administrative actions

### Scripts (`script/`)

#### `DeployMerkleAirdrop.s.sol`
- **Purpose**: Initial deployment script
- **Deploys**: BagelToken, MerkleAirdrop implementation, ERC1967 Proxy
- **Configures**: Merkle root, token distribution, role assignments

#### `MakeRoot/GenerateInput.s.sol`
- **Purpose**: Generate whitelist input JSON
- **Output**: `input.json` with addresses and amounts
- **Configurable**: Whitelist addresses and token amounts

#### `MakeRoot/MakeMerkle.s.sol`
- **Purpose**: Generate Merkle proofs and root hash
- **Input**: `input.json` from GenerateInput
- **Output**: `output.json` with proofs for each address

#### `UpgradeAirdrop/Upgrading.s.sol`
- **Purpose**: Upgrade from V1 to V2 implementation
- **Features**: Safe upgrade with storage validation

### Tests (`test/`)

#### `MerkleAirdropTest.t.sol`
- **Coverage**: Core functionality testing
- **Tests**: Claim validation, access control, Merkle proof verification

## Prerequisites

- **Foundry**: Latest version installed
- **Git**: For version control
- **RPC Endpoint**: Alchemy/Infura for testnet/mainnet deployment
- **Private Key**: For deployment and testing (use testnet keys only)

### Foundry Installation

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Installation

### Quick Start

```bash
git clone <repository-url>
cd AC-capstone
forge install
forge build
```

### Verify Installation

```bash
forge --version
cast --version
anvil --version
```

## Configuration

### Environment Variables

Create a `.env` file in the project root:

```bash
# RPC Endpoints
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID

# Private Keys (use testnet keys only)
PRIVATE_KEY=your_private_key_here

# Optional: Etherscan API for verification
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### Foundry Configuration

The `foundry.toml` includes:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]

remappings = [
    '@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts',
    'murky/=lib/murky/',
    'foundry-devops/=lib/foundry-devops',
    '@openzeppelin/contracts-upgradeable=lib/openzeppelin-contracts-upgradeable/contracts',
    '@openzeppelin/foundry-upgrades=lib/openzeppelin-foundry-upgrades/contracts',
]

fs_permissions = [{ access = "read-write", path = "./" }]
ffi = true
```

## Usage

### Quick Start

```bash
# Build contracts
forge build

# Run tests
forge test

# Deploy to local network
anvil
# In another terminal:
forge script script/DeployMerkleAirdrop.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Detailed Workflow

#### Step 1: Generate Merkle Tree

```bash
# Generate input.json with whitelist addresses
forge script script/MakeRoot/GenerateInput.s.sol

# Generate Merkle proofs and root
forge script script/MakeRoot/MakeMerkle.s.sol
```

**Input Structure** (`script/MakeRoot/input.json`):
```json
{
    "types": ["address", "uint"],
    "count": 4,
    "values": {
        "0": {
            "0": "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D",
            "1": "25000000000000000000"
        }
    }
}
```

**Output Structure** (`script/MakeRoot/output.json`):
```json
[
    {
        "inputs": ["0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D", "25000000000000000000"],
        "proof": ["0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a"],
        "root": "0x222c3eef4ef2bf020d38a34e9f5b402c296b08680605a9a921533d3befb7a107",
        "leaf": "0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad"
    }
]
```

#### Step 2: Deploy Contracts

```bash
forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

**What Gets Deployed:**
1. **BagelToken**: ERC20 token contract
2. **MerkleAirdrop Implementation**: Logic contract (V1)
3. **ERC1967 Proxy**: Points to implementation, stores state
4. **Token Distribution**: Tokens transferred to proxy for distribution

#### Step 3: Users Claim Tokens

Users interact with the `claim(address account, uint256 amount, bytes32[] calldata merkleProof)` function:

```bash
# Using Cast (example)
cast send $PROXY_ADDRESS \
  "claim(address,uint256,bytes32[])" \
  $USER_ADDRESS \
  $AMOUNT \
  "[$PROOF1,$PROOF2]" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $USER_PRIVATE_KEY
```

#### Step 4: Upgrade to V2

```bash
forge script script/UpgradeAirdrop/Upgrading.s.sol:UpgradeMerkle \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

**V2 New Capabilities:**
- Update Merkle root for new airdrop rounds
- Change the token being distributed
- Enhanced administrative controls

## Testing

### Running Tests

```bash
# Run all tests
forge test

# Verbose output
forge test -vvv

# Coverage report
forge coverage

# Run specific test
forge test --match-test testUserInWhiteListCanClaim
```

### Test Descriptions

#### `MerkleAirdropTest.t.sol`

**`testUserInWhiteListCanClaim()`**
- **Purpose**: Validates legitimate users can claim tokens
- **Process**:
  1. User with valid Merkle proof calls `claim()`
  2. Verifies token transfer occurs
  3. Checks balance increase matches claim amount

**`testUserNotInWhiteListCanNotClaim()`**
- **Purpose**: Ensures non-whitelisted addresses are rejected
- **Process**:
  1. Non-whitelisted user attempts to claim
  2. Verifies transaction reverts with `MerkleAirdrop__InvalidProof()`

**`testClaimedCheck()`**
- **Purpose**: Verifies claim status tracking
- **Process**:
  1. User claims tokens
  2. Checks `getClaimedCheck()` returns `true`
  3. Ensures double-claim prevention works

### Test Strategy

- **Unit Tests**: Individual contract function testing
- **Integration Tests**: Deployment and upgrade flow testing
- **Merkle Proof Tests**: Verification logic testing
- **Access Control Tests**: Role-based permission testing
- **Edge Cases**: Invalid inputs, boundary conditions

## Deployed Contracts (Example)

```
Network: Sepolia Testnet (Chain ID: 11155111)
Proxy: 0x32Fa0b80620D3439cA16dA7DBa95dCb73cD64eCD
BagelToken: 0xEeE1A3C2f55cca4178C9D17233Bc484136A48351
```

*Note: These are example deployments for reference. Always verify contract addresses before interacting.*

## Architecture Deep Dive

### UUPS Proxy Pattern

**Why UUPS over Transparent Proxy:**
- **Gas Efficiency**: Direct calls to implementation (no admin overhead)
- **Upgrade Control**: Implementation contract controls upgrades
- **Security**: Upgrade authorization in implementation logic

**Storage Layout Considerations:**
```solidity
// Storage gap for future upgrades
uint256[45] private __gap;
```

**Authorization Mechanism:**
```solidity
bytes32 private constant CAN_UPGRADE_ROLE = keccak256("CAN_UPGRADE_ROLE");

function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(CAN_UPGRADE_ROLE)
{}
```

### Merkle Tree Implementation

**Double Hashing for Security:**
```solidity
bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
```

**Why Double Hashing:**
- **Preimage Attack Protection**: Prevents attackers from finding inputs that hash to known values
- **Collision Resistance**: Reduces risk of hash collisions
- **Industry Standard**: Follows OpenZeppelin's Merkle proof implementation

**Proof Verification Process:**
1. User provides `(account, amount, merkleProof)`
2. Contract constructs leaf hash
3. `MerkleProof.verify()` validates proof against stored root
4. If valid, tokens are transferred to user

### Security Features

- **Double-Claim Prevention**: `mapping(address => bool) s_hasClaimed`
- **Role-Based Upgrades**: `CAN_UPGRADE_ROLE` authorization
- **Safe Token Transfers**: `SafeERC20` for external token compatibility
- **EIP-712 Support**: Prepared for signature-based claims (future feature)

## Gas Optimization

### Merkle Proofs vs Storage

**Traditional Approach (Inefficient):**
```solidity
mapping(address => uint256) public whitelist;
// Gas cost: ~20,000 per address stored
```

**Merkle Tree Approach (Efficient):**
```solidity
bytes32 public merkleRoot;
// Gas cost: ~5,000 per claim (regardless of whitelist size)
```

**Savings Calculation:**
- 1,000 addresses: 20M gas vs 5M gas (75% savings)
- 10,000 addresses: 200M gas vs 5M gas (97.5% savings)

### Additional Optimizations

- **Calldata Usage**: Proof arrays passed as `calldata` (cheaper than `memory`)
- **Storage Gaps**: `__gap` prevents storage collision during upgrades
- **Packed Structs**: Efficient storage layout

## Development Workflow

### Code Quality

```bash
# Format code
forge fmt

# Check formatting
forge fmt --check

# Lint (if configured)
forge fmt --check
```

### Gas Analysis

```bash
# Generate gas snapshots
forge snapshot

# Compare gas usage
forge snapshot --diff
```

### Testing Workflow

```bash
# Run specific test with detailed output
forge test --match-test testUserInWhiteListCanClaim -vvv

# Run tests with gas reporting
forge test --gas-report

# Run tests in parallel
forge test --parallel
```

### Deployment Workflow

```bash
# Deploy and verify
forge script script/DeployMerkleAirdrop.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

## Troubleshooting

### Common Issues

**FFI Permissions Error:**
```bash
# Solution: Update foundry.toml
fs_permissions = [{ access = "read-write", path = "./" }]
ffi = true
```

**Proxy Initialization Error:**
```bash
# Ensure initialize() is called after deployment
# Check that proxy address is used, not implementation
```

**Upgrade Validation Failures:**
```bash
# Verify storage layout compatibility
# Check that new implementation inherits from previous
# Ensure __gap variables are properly sized
```

**Merkle Proof Verification Fails:**
```bash
# Verify leaf construction matches proof generation
# Check that account and amount match exactly
# Ensure proof array is in correct order
```

## Security Considerations

### Audit Recommendations

- **Professional Audit**: Recommended for mainnet deployment
- **Storage Layout**: Verify upgrade compatibility
- **Access Control**: Review role assignments and permissions
- **Merkle Root**: Ensure secure generation and distribution

### Known Limitations

- **Single Token**: Currently supports one token type per airdrop
- **Fixed Amounts**: Token amounts are fixed per address
- **Centralized Control**: Owner controls Merkle root updates

### Upgrade Safety Checklist

- [ ] Storage layout compatibility verified
- [ ] New functions don't conflict with existing
- [ ] Access control properly configured
- [ ] Events properly emitted
- [ ] Gas limits considered for new functions

### Private Key Management

- **Never commit private keys to repository**
- **Use environment variables for sensitive data**
- **Use hardware wallets for production deployments**
- **Rotate keys regularly**

## Project Structure

```
AC-capstone/
├── src/                    # Smart contracts
│   ├── BagelToken.sol     # ERC20 token
│   ├── MerkleAirdrop.sol  # V1 implementation
│   └── MerkleAirdropV2.sol # V2 implementation
├── script/                 # Deployment and utility scripts
│   ├── DeployMerkleAirdrop.s.sol
│   ├── MakeRoot/
│   │   ├── GenerateInput.s.sol
│   │   └── MakeMerkle.s.sol
│   └── UpgradeAirdrop/
│       └── Upgrading.s.sol
├── test/                   # Test suite
│   ├── MerkleAirdropTest.t.sol
│   └── UpgradeTest.t.sol
├── lib/                    # Dependencies
│   ├── forge-std/
│   ├── foundry-devops/
│   ├── murky/
│   └── openzeppelin-contracts/
├── broadcast/              # Deployment artifacts
└── zkout/                  # Compiled artifacts
```

## Contributing

### Development Guidelines

1. **Code Style**: Follow Solidity style guide
2. **Testing**: Write tests for all new functionality
3. **Documentation**: Update README for new features
4. **Commits**: Use conventional commit messages

### Pull Request Process

1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request with description
5. Address review feedback

## Educational Notes

### Key Learning Objectives Achieved

- **UUPS Upgrade Pattern**: Understanding proxy-based upgrades
- **Merkle Proof Systems**: Efficient cryptographic verification
- **Production Practices**: Testing, deployment, and security
- **Gas Optimization**: Efficient smart contract design

### Capstone Project Value

This project demonstrates:
- **Advanced Solidity Patterns**: UUPS, role-based access control
- **Cryptographic Security**: Merkle proof implementation
- **Production Readiness**: Comprehensive testing and documentation
- **Upgrade Mechanisms**: Safe contract evolution

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **OpenZeppelin**: For upgradeable contracts and security standards
- **Murky Library**: For Merkle tree generation utilities
- **Foundry Team**: For the excellent development framework
- **Ethereum Community**: For Merkle proof standards and best practices

## Resources & Further Reading

### UUPS Documentation
- [OpenZeppelin UUPS Guide](https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable)
- [UUPS vs Transparent Proxies](https://docs.openzeppelin.com/contracts/4.x/api/proxy#transparent-vs-uups)

### Merkle Tree Resources
- [Merkle Trees in Solidity](https://blog.ethereum.org/2015/11/15/merkling-in-ethereum/)
- [OpenZeppelin MerkleProof](https://docs.openzeppelin.com/contracts/4.x/api/utils#MerkleProof)

### Foundry Development
- [Foundry Book](https://book.getfoundry.sh/)
- [Forge Testing](https://book.getfoundry.sh/forge/tests)
- [Cast Commands](https://book.getfoundry.sh/reference/cast/)

### Security Best Practices
- [Smart Contract Security](https://consensys.github.io/smart-contract-best-practices/)
- [OpenZeppelin Security](https://docs.openzeppelin.com/contracts/4.x/security)
