// SPDX-License-Identifier: MIT

/*******************************************************************************
***
*** Deployed on Rinkeby testnet at 0x0C2E7d9CC784e85fC06B2f31248897218a815583
***
********************************************************************************/

pragma solidity ^0.6.0;

import "./AccessControl.sol";
import "./Context.sol";
import "./ERC20Burnable.sol";

/**
 * @dev Token ERC20 (based on OpenZeppelin v.3.1.0-20200702), including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a banker role that allows for others' tokens management (transfer, burning, allowance)
 *  - an admin role that allows to manage other roles
 *  - an owner address that can manage the admin role
 */
contract TokenESJ is Context, AccessControl, ERC20Burnable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BANKER_ROLE = keccak256("BANKER_ROLE");

    constructor (
        string memory name,
        string memory symbol,
        address initialAccount,
        uint256 initialBalance,
        uint8 decimals
    ) public payable ERC20(name, symbol) {
        _setupDecimals(decimals);
        _mint(initialAccount, initialBalance);

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(BANKER_ROLE, _msgSender());
    }

/********************************************************************************
***
*** MINTING FUNCTIONS
***
*********************************************************************************/

    /**
     * @dev Creates `amount` new tokens for `account`.
     *
     * - reserved to `MINTER_ROLE`.
     */
    function mint(address account, uint256 amount) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20 mint: must have minter role to mint");
        _mint(account, amount);
    }

/********************************************************************************
***
*** FORCE TRANSFER FUNCTIONS
***
*********************************************************************************/

    /**
     * @dev Force moves `value` tokens from the ``from``'s account to ``to``'s account.
     *
     * - reserved to `BANKER_ROLE`.
     */
    function transferInternal(address from, address to, uint256 value) public {
        require(hasRole(BANKER_ROLE, _msgSender()), "ERC20 transfer: must have banker role to transfer others' tokens");
        _transfer(from, to, value);
    }

    /**
     * @dev Destroys `amount` tokens from the ``account``'s account.
     *
     * - reserved to `BANKER_ROLE`.
     */
    function burnInternal(address account, uint256 amount) public {
        require(hasRole(BANKER_ROLE, _msgSender()), "ERC20 burn: must have banker role to burn others' tokens");
        _burn(account, amount);
    }

    /**
     * @dev Force sets `value` as the allowance of `spender` over the ``owner``'s tokens.
     *
     * - reserved to `BANKER_ROLE`.
     */
    function approveInternal(address owner, address spender, uint256 value) public {
        require(hasRole(BANKER_ROLE, _msgSender()), "ERC20 approve: must have banker role to approve spending of others' tokens");
        _approve(owner, spender, value);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
