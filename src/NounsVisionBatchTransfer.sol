// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ERC721Like {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function setApprovalForAll(address operator, bool approved) external;
}

contract NounsVisionBatchTransfer {
    ERC721Like public constant NOUNS_VISION =
        ERC721Like(0xd8e6b954f7d3F42570D3B0adB516f2868729eC4D);

    address public constant NOUNS_DAO =
        0x0BC3807Ec262cB779b38D65b38158acC3bfedE10;

    mapping(address => uint256) public allowanceFor;

    error NotNounsDAO();
    error NotEnoughOwned();
    error NotEnoughAllowance();

    modifier onlyNounsDAO() {
        if (msg.sender != NOUNS_DAO) revert NotNounsDAO();
        _;
    }

    /// @notice Calculate the first token ID owned by Nouns DAO and the maximum batch amount possible from this ID for a spender
    /// @dev Will revert NotEnoughOwned() if Nouns DAO has no balance
    /// @return startId The first tokenId owned by Nouns DAO
    /// @return amount The maximum batch amount from the startId for this spender
    function getStartIdAndBatchAmount(address spender)
        public
        view
        returns (uint256 startId, uint256 amount)
    {
        amount = NOUNS_VISION.balanceOf(NOUNS_DAO);

        if (amount == 0) {
            revert NotEnoughOwned();
        }

        // Nouns DAO was sent 500 Nouns Vision Glasses starting from tokenId 751
        for (startId = 751; startId <= 1250; startId++) {
            try NOUNS_VISION.ownerOf(startId) returns (address owner) {
                if (owner != NOUNS_DAO) continue;
                break;
            } catch {}
        }

        for (amount; amount > 0; amount--) {
            try NOUNS_VISION.ownerOf(startId + amount - 1) returns (
                address owner
            ) {
                if (owner == NOUNS_DAO) break;
            } catch {}
        }

        if (amount > allowanceFor[spender]) amount = allowanceFor[spender];
    }

    /// @notice Add an allowance for spender address to batch send an amount of Nouns Vision Glasses
    /// @param spender Address to allow
    /// @param amount Batch amount allowed
    function addAllowance(address spender, uint256 amount)
        external
        onlyNounsDAO
    {
        allowanceFor[spender] += amount;
    }

    function disallow(address spender) external onlyNounsDAO {
        delete allowanceFor[spender];
    }

    /// @notice Send `msg.sender` a batch `amount` of tokens from `startId.` Use `getStartIdAndBatchAmount(address)` to determine these values
    /// @dev Will revert:
    /// @dev  - NotEnoughAllowance(): Spender has not been granted enough allowance to transfer
    /// @dev  - NotEnoughOwned(): Nouns DAO balance is below the requested amount
    /// @param startId The starting ID of the batch token transfer
    /// @param amount The batch amount of tokens to be transfered
    function batchTransfer(uint256 startId, uint256 amount) external {
        uint256 allowance = allowanceFor[msg.sender];

        if (amount > allowance) {
            revert NotEnoughAllowance();
        }
        if (amount > NOUNS_VISION.balanceOf(NOUNS_DAO)) {
            revert NotEnoughOwned();
        }

        allowanceFor[msg.sender] = allowance - amount;

        for (uint256 i; i < amount; i++) {
            NOUNS_VISION.transferFrom(NOUNS_DAO, msg.sender, startId + i);
        }
    }
}
