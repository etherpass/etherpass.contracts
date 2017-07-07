pragma solidity ^0.4.1;
import '../installed_contracts/zeppelin/contracts/ownership/Ownable.sol';
import '../installed_contracts/zeppelin/contracts/token/BasicToken.sol';
import './etherpass_storage.sol';
import './etherpass_token.sol';

contract EtherpassManager is Ownable, BasicToken {

    EtherpassStorage private _storage;
    EtherpassToken private _tokens;

    function EtherpassManager(address storageAddr, address tokenContract) {        
        _storage = EtherpassStorage(storageAddr);
        _tokens = EtherpassToken(tokenContract);
    }

    function setValue(address addr, bytes key, bytes value, bytes sign, uint tokenPrice) onlyOwner {
        _tokens.internalTransfer(addr, tokenPrice);
        _storage.setValue(key, value, sign);
    }    
}