var Etherpass = artifacts.require("Etherpass");
var signer  = require('./signer.js')
const ethUtil = require('ethereumjs-util');

contract('Etherpass', function(accounts) {

    var private_key = "4085dde01ea641a0f4fd6586ca11fc1f5df38e1bdcbef501da970cad9335b389"
    
    it("test set and get password", function(){
        var url = "0x1200";
        var password = "0x0123"                

        var setSign = signer.signHash(signer.getHash(url, password), private_key);
        var getSign = signer.signHash(signer.getHash(url), private_key);                        

        var etherpass = null;
        return Etherpass.deployed()       
        .then(function(instance){           
            etherpass = instance;
            return etherpass.setPassword(url, password, setSign);
        })
        .then(function(){
            return etherpass.getPassword.call(url, getSign);            
        }).then(function(storedPassword){            
            assert.equal(password, storedPassword, "returned password is wrong");            
        }).then(function(){
            return etherpass.getPassword.call(url, setSign) //wrong signature
                .then(function(storedPassword){
                    assert.equal("0x", storedPassword, "must return empty password");
                });
        });
    })
});