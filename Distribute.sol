// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract Distribute {

    error NoDistributionYet();
    error ContributorIsNotDuePayment();
    error PaymentFailed();
    error ContributorIsZeroAddress();
    error SharesAreZero();
    error ContributorAlreadyHasShares();
    error ContributorHasNoShares();

    uint256 private _totalShares;
    uint256 private _totalReleased;
    uint256 public immutable createTime;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;

    address[] public contributors;
    constructor(address[6] memory _contributors, uint256[6] memory shares_) payable {
        createTime = block.timestamp;
        for (uint256 i = 0; i < _contributors.length; ) {
            _addContributor(_contributors[i], shares_[i]);
            unchecked {
                ++i;
            }
        }  
    }
    receive() external payable {}

    fallback() external payable {}

    /**
     * @dev Getter for the total shares held by contributors.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the amount of shares held by a contributor.
     */
    function shares(address contributor) public view returns (uint256) {
        return _shares[contributor];
    }

    /**
     * @dev Getter for the amount of Ether already released to a contributor.
     */
    function released(address contributor) public view returns (uint256) {
        return _released[contributor];
    }

    /**
     * @dev Getter for the address of the contributor number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return contributors[index];
    }

    /**
     * @dev Triggers a transfer to `contributor` of the amount of Ether they are owed
     */
    function distribute(address payable contributor) public {

        if (_shares[contributor] <= 0) {
            revert ContributorHasNoShares();
        }

        if (block.timestamp <= createTime + 2 weeks) {
            revert NoDistributionYet();
        }

        uint256 totalReceived = address(this).balance + (_totalReleased);
        uint256 payment = (totalReceived * _shares[contributor])/(_totalShares) - (_released[contributor]);

        if (payment <= 0) {
            revert ContributorIsNotDuePayment();
        }

        _released[contributor] = _released[contributor]+ (payment);
        _totalReleased = _totalReleased + payment;

        (bool success, ) = contributor.call{value: payment}("");
        if (!success) {
            revert PaymentFailed();
        }
    }

    /**
     * @dev Add a new contributor to the contract.
     * @param contributor The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _addContributor(address contributor, uint256 shares_) private {
        
        if (contributor == address(0)) {
            revert ContributorIsZeroAddress();
        }
        if (shares_ <= 0) {
            revert SharesAreZero();
        }
        if (_shares[contributor] != 0)
         {
            revert ContributorAlreadyHasShares();
        }
        contributors.push(contributor);
        _shares[contributor] = shares_;
        _totalShares = _totalShares + shares_;
    }
}