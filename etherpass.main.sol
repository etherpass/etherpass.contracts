pragma solidity ^0.4.1;
import 'zeppelin/ownership/Ownable.sol';
contract Etherpass is Ownable {

    mapping (address => mapping(bytes => bytes)) private _storage;


    function getPassword(bytes url, bytes password, bytes sign) returns (bytes) {
        bytes32 hash = sha3(url, password); 
        address owner = _getAddress(hash, sign);
        return _storage[owner][url];
    }

    function setPassword(bytes url, bytes password, bytes sign){
        bytes32 hash = sha3(url, password); 
        address owner = _getAddress(hash, sign);
        _storage[owner][url] = password;
    }

    function _getAddress(bytes32 hash, bytes sig) private returns(address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := mload(add(sig, 65))
        }

        return ecrecover(hash, v, r, s);
    }
}