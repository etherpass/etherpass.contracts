pragma solidity ^0.4.1;
import '../installed_contracts/zeppelin/contracts/token/BasicToken.sol';
import '../installed_contracts/zeppelin/contracts/ownership/Ownable.sol';

contract EtherpassToken is BasicToken, Ownable {

     function internalTransfer (address from, uint value) onlyOwner {
        balances[from] = safeSub(balances[from], value);
        balances[owner] = safeAdd(balances[owner], value);
        Transfer(from, owner, value);
    }    


    function cashin(address to, uint value) onlyOwner{
        balances[to] = safeAdd(balances[to], value);        
    }
}