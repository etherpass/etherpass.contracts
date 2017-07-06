pragma solidity ^0.4.1;
import 'zeppelin/ownership/Ownable.sol';


contract Etherpass is Ownable {

    struct KeysGroup {     
        uint numKeys;
        mapping(uint => bytes) keys;
    }

    mapping (address => mapping(bytes32 => bytes)) private _storage;

    mapping (address => KeysGroup) private _indexes;

    //KeysGroup[] keyGroups = new KeysGroup[1];


    function getPassword(bytes key, bytes sign) returns (bytes) {
        bytes32 hash = sha3(key); 
        address owner = _getAddress(hash, sign);
        return _storage[owner][hash];
    }

    function setPassword(bytes key, bytes value, bytes sign){
        bytes32 hash = sha3(key, value); 
        address owner = _getAddress(hash, sign);
        _storage[owner][sha3(key)] = value;

        var keyGroup = _indexes[owner];

        keyGroup.keys[keyGroup.numKeys] = key;
        keyGroup.numKeys++;

        /*uint index = _indexes[owner];
        if (index == 0)
        {
            index = keyGroups.length;
            keyGroups.length++;            
            keyGroups[index] = KeysGroup();              
        }
        bool found = false;
        var map = keyGroups[index].keys;
          for(uint i=0;i<keyGroups[index].numKeys;i++)
            if (equalsArrays(map[i], key))
            {
                found = true;
                break;
            }
        if (!found)
        {            
            keyGroups[index].numKeys ++;
        }
        bytes keys = _keys[owner];
        bool setted = false;
        for(uint i=0;i<keys.length;i++)
            if (equalsArrays(keys[i], key))
            {
                keys[i] = key;
                setted = true;
                break;
            }
        if (!setted)
        {
            keys.length = keys.length+1;
            keys[keys.length-1] = key;
        }
        _keys[owner] = ref keys;*/
    }

    function getKeys(address addr) returns (bytes) {

        bytes storage result = new bytes(1);
        uint j = 0;
        for(uint i=0;i<_indexes[addr].numKeys;i++)
        {
            bytes key = _indexes[addr].keys[i];
            uint keyLengthIndex = j;
            j++;
            for(uint k=0;k< key.length;k++)
                {
                    result[keyLengthIndex] =  byte(uint(result[keyLengthIndex]) + 1);
                    result[j++] = key[k];
                    result.length = result.length + 1;
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