

```markdown
# Corporate Bond Protocol Smart Contract

## Overview

The Corporate Bond Protocol is a smart contract deployed on the Ethereum blockchain for managing corporate bonds. It provides a platform for registered companies to issue bonds, and users can purchase, transfer, and redeem these bonds.

## Features

### Company Registration

Companies can register on the platform by providing their name, description, and logo. The `registerCompany` function facilitates this registration process.
```

```solidity
/**
 * Registers a new company on the platform.
 * @param _name The name of the company.
 * @param _description The description of the company.
 * @param _logo The logo of the company.
 */
function registerCompany(string memory _name, string memory _description, string memory _logo) external;
```

### Bond Creation

Registered companies can create bonds using the `createBond` function. They specify the bond's name, maturity date, and annual interest rate. Bonds are issued in GHO tokens (an ERC20 token), and the contract keeps track of the total amount issued.

```solidity
/**
 * Creates a new corporate bond issued by the calling registered company.
 * @param _name The name of the bond.
 * @param _maturityDate The maturity date of the bond.
 * @param _interestRate The annual interest rate in basis points.
 * @return bondId The ID of the newly created bond.
 */
function createBond(string memory _name, uint256 _maturityDate, uint256 _interestRate) external onlyRegisteredCompany returns (uint256);
```

### Bond Purchase

Users can purchase bonds using the `purchaseBond` function. The purchase includes a principal amount and accrued interest. GHO tokens are transferred from the buyer to the contract, and the bond balances are updated accordingly.

```solidity
/**
 * Allows a user to purchase a corporate bond.
 * @param bondId The ID of the bond to be purchased.
 * @param principalAmount The principal amount to be invested in the bond.
 */
function purchaseBond(uint256 bondId, uint256 principalAmount) external;
```

### Bond Transfer

Bonds can be transferred between users using the `transferBond` function. The sender specifies the recipient and the amount to be transferred. This function ensures that the transfer is valid based on the bond balances.

```solidity
/**
 * Transfers a portion of a corporate bond from the sender to a recipient.
 * @param bondId The ID of the bond to be transferred.
 * @param to The address of the recipient.
 * @param amount The amount of the bond to be transferred.
 */
function transferBond(uint256 bondId, address to, uint256 amount) external;
```

### Bond Redemption

When a bond matures, users can redeem their bonds and receive the principal and accrued interest. The `redeemBond` function handles this process by transferring GHO tokens from the contract to the bond holder.

```solidity
/**
 * Redeems a matured corporate bond, transferring the principal and interest to the bond holder.
 * @param bondId The ID of the bond to be redeemed.
 */
function redeemBond(uint256 bondId) external;
```

### Interest Calculation

The contract includes a function `calculateInterest` to compute the interest amount based on the principal amount and annual interest rate. This is used in the purchase process.

```solidity
/**
 * Calculates the interest amount for a given principal amount and interest rate.
 * @param principalAmount The principal amount of the investment.
 * @param interestRate The annual interest rate in basis points.
 * @return interest The calculated interest amount.
 */
function calculateInterest(uint256 principalAmount, uint256 interestRate) internal view returns (uint256);
```

### Bond Information Retrieval

Several getter functions allow users to retrieve information about bonds. The `getAllBondIds` function provides an array of all bond IDs, and `getBondDetails` and `getBondBalance` retrieve specific details and balances for a given bond and account.

```solidity
/**
 * Retrieves an array of all bond IDs.
 * @return bondIds An array of all bond IDs.
 */
function getAllBondIds() external view returns (uint256[] memory);

/**
 * Retrieves details of a specific bond.
 * @param bondId The ID of the bond.
 * @return name The name of the bond.
 * @return maturityDate The maturity date of the bond.
 * @return interestRate The annual interest rate of the bond.
 * @return stablecoin The address of the stablecoin used for the bond.
 * @return totalIssued The total amount of the bond issued.
 */
function getBondDetails(uint256 bondId) external view returns (string memory name, uint256 maturityDate, uint256 interestRate, address stablecoin, uint256 totalIssued);

/**
 * Retrieves the balance of a specific bond for an account.
 * @param bondId The ID of the bond.
 * @param account The address of the account.
 * @return principalBalance The principal balance of the account in the bond.
 * @return interestAccrued The interest accrued for the account in the bond.
 */
function getBondBalance(uint256 bondId, address account) external view returns (uint256 principalBalance, uint256 interestAccrued);
```

## Usage

To interact with the smart contract, companies should use the `registerCompany` function to register, and registered companies can then create bonds using `createBond`. Users can purchase, transfer, and redeem bonds as needed.

## Deployment

The contract is currently deployed on the Ethereum blockchain. Ensure you have the correct GHO token address defined in the `GHO_TOKEN_ADDRESS` constant before deploying.


