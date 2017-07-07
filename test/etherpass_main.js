var EtherpassStorage = artifacts.require("EtherpassStorage");
var signer  = require('./signer.js')
const ethUtil = require('ethereumjs-util');

contract('EtherpassStorage', function(accounts) {

    var private_key = "0x4085dde01ea641a0f4fd6586ca11fc1f5df38e1bdcbef501da970cad9335b389";
    var address = "0x960336a077fb32d675405bd0a6cd0cb74aaa5062";
    
    it("test set and get value", function(){
        var key = "0x1234";
        var key2 = "0x9999";
        var value = "0x0123";

        var setSign = signer.signHash(signer.getHash(key, value), private_key);

        var setSign2 = signer.signHash(signer.getHash(key2, value), private_key);

        var getSign = signer.signHash(signer.getHash(key), private_key);                        

        var etherpass = null;
        return EtherpassStorage.deployed()       
        .then(function(instance){           
            etherpass = instance;
            return etherpass.setValue(key, value, setSign);
        }).then(function(){
            return etherpass.setValue(key2, value, setSign2);            
        })
        .then(function(){
            return etherpass.getKeys.call(address).then(function(data) {
                console.log(data);
            });            
        })
        .then(function(){
            return etherpass.getValue.call(key, getSign);            
        }).then(function(storedvalue){            
            assert.equal(value, storedvalue, "returned value is wrong");            
        }).then(function(){
            return etherpass.getValue.call(key, setSign) //wrong signature
                .then(function(storedvalue){
                    assert.equal("0x", storedvalue, "must return empty value");
                });
        });
    })


    it("test remove value", function(){
        var key1 = "0x01";
        var key2= "0x02";
        var value1 = "0x01";
        var value2 = "0x02";
        var sign1 = signer.signHash(signer.getHash(key1, value1), private_key);
        var sign2 = signer.signHash(signer.getHash(key2, value2), private_key);

        var sign3 = signer.signHash(signer.getHash(key1), private_key);
        var sign4 = signer.signHash(signer.getHash(key2), private_key);

        var etherpass = null;
        return EtherpassStorage.new()       
            .then(function(instance){           
                    etherpass = instance;
                    return etherpass.setValue(key1, value1, sign1).then(function(){
                        return etherpass.setValue(key2, value2, sign2);
                    });
            }).then(function(){
                return etherpass.getKeys.call(address).then(function(resp){
                    assert.equal("0x01010102", resp.valueOf(), "wrong keys list");
                });
            }).then(function(){
                return etherpass.removeKey(key1, sign3);
            }).then(function(){
                 return etherpass.getKeys.call(address).then(function(resp){
                    assert.equal("0x0102", resp.valueOf(), "wrong keys list after remove");
                });
            });
    });
});