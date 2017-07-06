var Etherpass = artifacts.require("Etherpass");
var signer  = require('./signer.js')
const ethUtil = require('ethereumjs-util');

contract('Etherpass', function(accounts) {

    var private_key = "0x4085dde01ea641a0f4fd6586ca11fc1f5df38e1bdcbef501da970cad9335b389";
    var address = "0x960336a077fb32d675405bd0a6cd0cb74aaa5062";
    
    it("test set and get password", function(){
        var url = "0x1234";
        var url2 = "0x9999";
        var password = "0x0123";

        var setSign = signer.signHash(signer.getHash(url, password), private_key);

        var setSign2 = signer.signHash(signer.getHash(url2, password), private_key);

        var getSign = signer.signHash(signer.getHash(url), private_key);                        

        var etherpass = null;
        return Etherpass.deployed()       
        .then(function(instance){           
            etherpass = instance;
            return etherpass.setPassword(url, password, setSign);
        }).then(function(){
            return etherpass.setPassword(url2, password, setSign2);            
        })
        .then(function(){
            return etherpass.getKeys.call(address).then(function(data) {
                console.log(data);
            });            
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