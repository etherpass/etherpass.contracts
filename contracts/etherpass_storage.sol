pragma solidity ^0.4.1;
import '../installed_contracts/zeppelin/contracts/ownership/Ownable.sol';


contract EtherpassStorage is Ownable {

    struct KeysGroup {     
        uint numKeys;
        mapping(uint => bytes) keys;
    }    

    mapping (address => mapping(bytes32 => bytes)) private _storage;

    mapping (address => KeysGroup) private _keyGroups;

    function getValue(bytes key, bytes sign) returns (bytes) {
        bytes32 hash = sha3(key); 
        address owner = _getAddress(hash, sign);
        return _storage[owner][hash];
    }

    function setValue(bytes key, bytes value, bytes sign){
        bytes32 hash = sha3(key, value); 
        address owner = _getAddress(hash, sign);
        bytes32 keyHash = sha3(key);
        if (_storage[owner][keyHash].length == 0)
        {
            _keyGroups[owner].keys[_keyGroups[owner].numKeys] = key;
            _keyGroups[owner].numKeys++;
        }
        _storage[owner][keyHash] = value;
    }

    function removeKey(bytes key, bytes sign){
        bytes32 hash = sha3(key); 
        address owner = _getAddress(hash, sign);
        delete _storage[owner][hash];
        var keys = _keyGroups[owner];
        for(var i=0; i<keys.numKeys;i++){
            if (equalsArrays(key, keys.keys[i]))
                delete keys.keys[i];
        }
    }

    function getKeys(address addr) returns (bytes) {
        uint i = 0;
        uint totalSize = 0;
        for(i=0;i<_keyGroups[addr].numKeys;i++)
        {
            var k = _keyGroups[addr].keys[i];
            if (k.length > 0)
                totalSize += k.length + 1;
        }            
        bytes memory result = new bytes(totalSize);

        uint index = 0;
        for(i=0;i<_keyGroups[addr].numKeys;i++)
        {
            var key = _keyGroups[addr].keys[i];
            if (key.length>0)
            {
                result[index++] = byte(key.length);
                for(uint j=0; j<key.length; j++)
                    result[index++] = key[j];
            }
        }
        return result;
    }

    function equalsArrays(bytes arr1, bytes arr2) returns (bool){
        if (arr1.length!=arr2.length) return false;
        for(uint i=0;i<arr1.length;i++)
            if (arr1[i]!=arr2[i])
                return false;
        return true;
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