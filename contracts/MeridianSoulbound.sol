// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Meridian Genesis Soulbound
 * @dev Developed by Renato for Meridian Hub (https://meridian-hub.xyz/)
 * @notice Soulbound Token (SBT) for the Meridian community on Arc Network.
 * Limit of 1 per wallet, non-transferable.
 */
contract MeridianSoulbound is ERC721, Ownable {
    uint256 public constant MAX_SUPPLY = 777;
    uint256 private _nextTokenId;

    error TokenIsSoulbound();
    error AlreadyMinted();
    error SoldOut();
    error TokenDoesNotExist();

    // IPFS CID for your JSON metadata
    string private constant METADATA_URI = "ipfs://bafkreigno35b42kjw27jib4dthbu33lefcmu4hyxxxzo7ixoarcts52kra";

    // Mapping to enforce 1 mint per address
    mapping(address => bool) public hasMinted;

    constructor() ERC721("Meridian Genesis Soulbound", "MHT") Ownable(msg.sender) {}

    /**
     * @dev Public minting function.
     */
    function mint() external {
        if (hasMinted[msg.sender]) revert AlreadyMinted();
        if (_nextTokenId >= MAX_SUPPLY) revert SoldOut();

        hasMinted[msg.sender] = true;
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    /**
     * @dev Returns the same metadata URI for all tokens.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) revert TokenDoesNotExist();
        return METADATA_URI;
    }

    /**
     * @dev Soulbound Logic: Prevents token transfers between wallets.
     * Only allows minting (from == address(0)) and burning (to == address(0)).
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        
        if (from != address(0) && to != address(0)) {
            revert TokenIsSoulbound();
        }
        
        return super._update(to, tokenId, auth);
    }

    /**
     * @dev Returns the current total supply.
     */
    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }
}
