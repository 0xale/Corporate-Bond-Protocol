// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title CorporateBondProtocol
 * @dev A smart contract for managing corporate bonds on the Ethereum blockchain.
 */
contract CorporateBondProtocol {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /**
     * @dev Struct to store company details.
     */
    struct Company {
        string name;
        string description;
        string logo; // Assuming logo is a string, you might want to use a different type depending on your requirements
    }

    /**
     * @dev Struct to store bond details.
     */
    struct CorporateBond {
        string name;
        uint256 maturityDate;
        uint256 interestRate; // Annual interest rate in basis points (1 basis point = 0.01%)
        IERC20 ghotoken;
        uint256 totalIssued;
        mapping(address => uint256) principalBalances;
        mapping(address => uint256) interestAccrued;
    }

    // Mapping of registered companies
    mapping(address => Company) public registeredCompanies;

    // Mapping of corporate bonds
    mapping(uint256 => CorporateBond) public corporateBonds;
    uint256 public nextBondId;

    // Define the address of the ghotoken
    address public constant STABLECOIN_ADDRESS =
        0xc4bF5CbDaBE595361438F8c6a187bDc330539c60;

    // Modifier to check if a caller is a registered company
    modifier onlyRegisteredCompany() {
        require(
            bytes(registeredCompanies[msg.sender].name).length > 0,
            "Not a registered company"
        );
        _;
    }

    // Event emitted when a company is registered
    event CompanyRegistered(
        address indexed companyAddress,
        string name,
        string description,
        string logo
    );

    // Event emitted when a bond is created
    event BondCreated(
        uint256 bondId,
        string name,
        uint256 maturityDate,
        uint256 interestRate,
        address ghotoken,
        uint256 totalIssued
    );

    // Event emitted when a bond is purchased
    event BondPurchased(
        uint256 bondId,
        address indexed buyer,
        uint256 principalAmount,
        uint256 interestAmount
    );

    // Event emitted when a bond is transferred
    event BondTransferred(
        uint256 bondId,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    // Event emitted when a bond is redeemed
    event BondRedeemed(
        uint256 bondId,
        address indexed holder,
        uint256 principalAmount,
        uint256 interestAmount
    );

    /**
     * @dev Company registration function with additional details.
     * @param _name The name of the company.
     * @param _description The description of the company.
     * @param _logo The logo of the company.
     */
    function registerCompany(
        string memory _name,
        string memory _description,
        string memory _logo
    ) external {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");

        // Register the company with details
        registeredCompanies[msg.sender] = Company({
            name: _name,
            description: _description,
            logo: _logo
        });

        emit CompanyRegistered(msg.sender, _name, _description, _logo);
    }

    /**
     * @dev Function to create a bond (only callable by registered companies).
     * @param _name The name of the bond.
     * @param _maturityDate The maturity date of the bond.
     * @param _interestRate The annual interest rate in basis points.
     * @return bondId The ID of the newly created bond.
     */
    function createBond(
        string memory _name,
        uint256 _maturityDate,
        uint256 _interestRate
    ) external onlyRegisteredCompany returns (uint256) {
        CorporateBond storage newBond = corporateBonds[nextBondId];
        newBond.name = _name;
        newBond.maturityDate = _maturityDate;
        newBond.interestRate = _interestRate;
        newBond.ghotoken = IERC20(STABLECOIN_ADDRESS);

        emit BondCreated(
            nextBondId,
            _name,
            _maturityDate,
            _interestRate,
            STABLECOIN_ADDRESS,
            0
        );

        nextBondId++;
        return nextBondId - 1;
    }

    /**
     * @dev Function to purchase a bond.
     * @param bondId The ID of the bond to be purchased.
     * @param principalAmount The principal amount to be invested in the bond.
     */
    function purchaseBond(uint256 bondId, uint256 principalAmount) external {
        CorporateBond storage bond = corporateBonds[bondId];
        require(block.timestamp < bond.maturityDate, "Bond has matured");
        require(
            principalAmount > 0,
            "Principal amount must be greater than zero"
        );

        uint256 interest = calculateInterest(
            principalAmount,
            bond.interestRate
        );
        uint256 totalAmount = principalAmount.add(interest);

        // Transfer stablecoins from buyer to the contract
        bond.ghotoken.safeTransferFrom(msg.sender, address(this), totalAmount);

        // Update bond state
        bond.principalBalances[msg.sender] = bond
            .principalBalances[msg.sender]
            .add(principalAmount);
        bond.interestAccrued[msg.sender] = bond.interestAccrued[msg.sender].add(
            interest
        );
        bond.totalIssued = bond.totalIssued.add(totalAmount);

        emit BondPurchased(bondId, msg.sender, principalAmount, interest);
    }

    /**
     * @dev Function to transfer a bond.
     * @param bondId The ID of the bond to be transferred.
     * @param to The address of the recipient.
     * @param amount The amount of the bond to be transferred.
     */
    function transferBond(uint256 bondId, address to, uint256 amount) external {
        CorporateBond storage bond = corporateBonds[bondId];
        require(msg.sender != to, "Cannot transfer to yourself");
        require(amount > 0, "Amount must be greater than zero");
        require(
            amount <= bond.principalBalances[msg.sender],
            "Insufficient balance"
        );

        // Transfer bond from sender to the recipient
        bond.principalBalances[msg.sender] = bond
            .principalBalances[msg.sender]
            .sub(amount);
        bond.principalBalances[to] = bond.principalBalances[to].add(amount);

        emit BondTransferred(bondId, msg.sender, to, amount);
    }

    /**
     * @dev Function to redeem a bond.
     * @param bondId The ID of the bond to be redeemed.
     */
    function redeemBond(uint256 bondId) external {
        CorporateBond storage bond = corporateBonds[bondId];
        require(
            block.timestamp >= bond.maturityDate,
            "Bond has not matured yet"
        );

        uint256 principalAmount = bond.principalBalances[msg.sender];
        uint256 interestAmount = bond.interestAccrued[msg.sender];

        require(principalAmount > 0, "No bonds to redeem");

        // Transfer stablecoins (principal + interest) from contract to the bond holder
        bond.ghotoken.safeTransfer(
            msg.sender,
            principalAmount.add(interestAmount)
        );

        // Clear the bond holder's balances
        bond.principalBalances[msg.sender] = 0;
        bond.interestAccrued[msg.sender] = 0;

        emit BondRedeemed(bondId, msg.sender, principalAmount, interestAmount);
    }

    /**
     * @dev Internal function to calculate interest for a given principal amount and interest rate.
     * @param principalAmount The principal amount of the investment.
     * @param interestRate The annual interest rate in basis points.
     * @return interest The calculated interest amount.
     */
    function calculateInterest(
        uint256 principalAmount,
        uint256 interestRate
    ) internal view returns (uint256) {
        // Calculate simple interest using SafeMath
        uint256 maturityDate = corporateBonds[nextBondId].maturityDate;

        // Ensure maturityDate is in the future
        uint256 daysToMaturity = maturityDate > block.timestamp
            ? maturityDate.sub(block.timestamp)
            : 0;

        uint256 interest = principalAmount
            .mul(interestRate)
            .mul(daysToMaturity)
            .div(365 days)
            .div(10000);

        return interest;
    }

    /**
     * @dev Getter function for all bond IDs.
     * @return bondIds An array of all bond IDs.
     */
    function getAllBondIds() external view returns (uint256[] memory) {
        uint256[] memory bondIds = new uint256[](nextBondId);
        for (uint256 i = 0; i < nextBondId; i++) {
            bondIds[i] = i;
        }
        return bondIds;
    }

    /**
     * @dev Getter function for bond details.
     * @param bondId The ID of the bond.
     * @return name The name of the bond.
     * @return maturityDate The maturity date of the bond.
     * @return interestRate The annual interest rate of the bond.
     * @return ghotoken The address of the ghotoken used for the bond.
     * @return totalIssued The total amount of the bond issued.
     */
    function getBondDetails(
        uint256 bondId
    )
        external
        view
        returns (
            string memory name,
            uint256 maturityDate,
            uint256 interestRate,
            address ghotoken,
            uint256 totalIssued
        )
    {
        CorporateBond storage bond = corporateBonds[bondId];
        return (
            bond.name,
            bond.maturityDate,
            bond.interestRate,
            address(bond.ghotoken),
            bond.totalIssued
        );
    }

    /**
     * @dev Getter function for bond balance.
     * @param bondId The ID of the bond.
     * @param account The address of the account.
     * @return principalBalance The principal balance of the account in the bond.
     * @return interestAccrued The interest accrued for the account in the bond.
     */
    function getBondBalance(
        uint256 bondId,
        address account
    )
        external
        view
        returns (uint256 principalBalance, uint256 interestAccrued)
    {
        CorporateBond storage bond = corporateBonds[bondId];
        return (bond.principalBalances[account], bond.interestAccrued[account]);
    }
}
